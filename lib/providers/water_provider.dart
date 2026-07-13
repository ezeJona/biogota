import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../backend-api/api_service.dart';
import 'auth_user.dart';
import 'impacto_global_provider.dart';

// Estado del módulo de agua
class WaterState {
  final List<String> completadosHoy; // subtipos ya completados (ahora List para permitir repetidos)
  final int litrosHoy;              // suma del día del usuario
  final bool cargando;
  final String? error;

  const WaterState({
    this.completadosHoy = const [],
    this.litrosHoy = 0,
    this.cargando = false,
    this.error,
  });

  // Porcentaje para la gota (máximo visual = 100 L)
  double get progreso => (litrosHoy / 100).clamp(0.0, 1.0);

  WaterState copyWith({
    List<String>? completadosHoy,
    int? litrosHoy,
    bool? cargando,
    String? error,
  }) {
    return WaterState(
      completadosHoy: completadosHoy ?? this.completadosHoy,
      litrosHoy: litrosHoy ?? this.litrosHoy,
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

      // Calcular litros acumulados hoy sumando cada subtipo completado
      final litros = completados.fold<int>(
        0,
            (suma, subtipo) => suma + (_litrosPorSubtipo[subtipo] ?? 0),
      );

      state = state.copyWith(
        completadosHoy: completados,
        litrosHoy: litros,
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<void> completarReto(String subtipo) async {
    final esRepetible = _retosRepetibles.contains(subtipo);
    final yaCompletado = state.completadosHoy.contains(subtipo);

    // Si no es repetible y ya se completó, no hacer nada
    if (!esRepetible && yaCompletado) return;
    
    // Evitar doble tap mientras procesa
    if (state.cargando) return;

    // Optimistic update — actualiza UI antes de esperar la BD
    final litrosExtra = _litrosPorSubtipo[subtipo] ?? 0;
    state = state.copyWith(
      completadosHoy: [...state.completadosHoy, subtipo],
      litrosHoy: state.litrosHoy + litrosExtra,
    );

    try {
      await ApiService.registrarAccion(
        tipo: 'ducha',
        subtipo: subtipo,
        usuarioId: _usuarioId,
      );
      
      // FORZAR ACTUALIZACIÓN DEL IMPACTO GLOBAL
      // Esto hace que el Home se actualice inmediatamente para este usuario
      _ref.invalidate(impactoGlobalProvider);
      
    } catch (e) {
      // Revertir si la BD rechaza
      final nuevaLista = List<String>.from(state.completadosHoy);
      // Remover la última instancia agregada del subtipo
      for (int i = nuevaLista.length - 1; i >= 0; i--) {
        if (nuevaLista[i] == subtipo) {
          nuevaLista.removeAt(i);
          break;
        }
      }

      state = state.copyWith(
        completadosHoy: nuevaLista,
        litrosHoy: state.litrosHoy - litrosExtra,
        error: e.toString(),
      );
    }
  }
}

final waterProvider =
StateNotifierProvider.autoDispose<WaterNotifier, WaterState>((ref) {
  final authUser = ref.watch(authUserProvider);
  return WaterNotifier(authUser?.id ?? '', ref);
});