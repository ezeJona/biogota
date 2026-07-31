import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../backend-api/api_service.dart';
import 'auth_user.dart';
import 'app_user.dart';
import 'impacto_global_provider.dart';
import 'ranking_provider.dart';

// Estado del módulo de agua
class WaterState {
  final List<String> completadosHoy; // subtipos ya completados (ahora List para permitir repetidos)
  final int litrosHoy;              // suma del día del usuario
  final int co2Hoy;                 // suma de CO2 evitado hoy por el usuario
  final bool cargando;
  final String? error;

  const WaterState({
    this.completadosHoy = const [],
    this.litrosHoy = 0,
    this.co2Hoy = 0,
    this.cargando = false,
    this.error,
  });

  // Porcentaje para la gota (máximo visual = 100 L)
  double get progreso => (litrosHoy / 100).clamp(0.0, 1.0);

  WaterState copyWith({
    List<String>? completadosHoy,
    int? litrosHoy,
    int? co2Hoy,
    bool? cargando,
    String? error,
  }) {
    return WaterState(
      completadosHoy: completadosHoy ?? this.completadosHoy,
      litrosHoy: litrosHoy ?? this.litrosHoy,
      co2Hoy: co2Hoy ?? this.co2Hoy,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class WaterNotifier extends StateNotifier<WaterState> {
  final String _usuarioId;
  final Ref _ref; // Añadido para poder invalidar otros providers

  // Impacto local por subtipo — espeja las fórmulas de la BD
  static const Map<String, int> _litrosPorSubtipo = {
    'ducha_express': 40,
    'cierre_grifo': 5,
    'guardian_agua': 20,
  };

  // Equivalencia de CO2 por subtipo (espejo de la BD)
  static const Map<String, int> _co2PorSubtipo = {
    'ducha_express': 800,
    'cierre_grifo': 10,
    'guardian_agua': 100,
  };

  // Definir cuáles retos son repetibles
  static const Set<String> _retosRepetibles = {
    'cierre_grifo',
    'guardian_agua',
  };

  WaterNotifier(this._usuarioId, this._ref) : super(const WaterState()) {
    cargarRetosDeHoy();
  }

  Future<void> cargarRetosDeHoy() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final completados = await ApiService.getSubtiposCompletadosHoy(
        usuarioId: _usuarioId,
        tipo: 'ducha',
      );

      // Calcular litros y CO2 acumulados hoy
      int litros = 0;
      int co2 = 0;
      for (final subtipo in completados) {
        litros += _litrosPorSubtipo[subtipo] ?? 0;
        co2 += _co2PorSubtipo[subtipo] ?? 0;
      }

      state = state.copyWith(
        completadosHoy: completados,
        litrosHoy: litros,
        co2Hoy: co2,
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<void> completarReto(String subtipo) async {
    final esRepetible = _retosRepetibles.contains(subtipo);
    final yaCompletado = state.completadosHoy.contains(subtipo);

    if (!esRepetible && yaCompletado) return;
    if (state.cargando) return;

    final litrosExtra = _litrosPorSubtipo[subtipo] ?? 0;
    final co2Extra = _co2PorSubtipo[subtipo] ?? 0;

    // Optimistic Update
    if (!state.completadosHoy.contains(subtipo) || esRepetible) {
      state = state.copyWith(
        completadosHoy: [...state.completadosHoy, subtipo],
        litrosHoy: state.litrosHoy + litrosExtra,
        co2Hoy: state.co2Hoy + co2Extra,
      );
    }

    try {
      await ApiService.registrarAccion(
        tipo: 'ducha',
        subtipo: subtipo,
        usuarioId: _usuarioId,
      );
      
      _ref.invalidate(impactoGlobalProvider);
      _ref.invalidate(rankingProvider);
      _ref.read(appUserProvider.notifier).fetch(); 
      
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('ya la completaste')) {
        // El servidor confirma que ya está hecho, mantenemos el estado bloqueado
        state = state.copyWith(error: errorMsg);
      } else {
        // Error real de red, revertimos
        final nuevaLista = List<String>.from(state.completadosHoy);
        nuevaLista.remove(subtipo);
        state = state.copyWith(
          completadosHoy: nuevaLista,
          litrosHoy: (state.litrosHoy - litrosExtra).clamp(0, 999),
          co2Hoy: (state.co2Hoy - co2Extra).clamp(0, 99999),
          error: errorMsg,
        );
      }
    }
  }
}

final waterProvider =
StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final authUser = ref.watch(authUserProvider);
  return WaterNotifier(authUser?.id ?? '', ref);
});