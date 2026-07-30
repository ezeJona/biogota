import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../backend-api/api_service.dart';
import 'auth_user.dart';
import 'app_user.dart';
import 'impacto_global_provider.dart';

class RecyclingState {
  final List<String> completadosHoy;
  final int co2Hoy;
  final int materialesHoy;
  final bool cargando;
  final String? error;

  const RecyclingState({
    this.completadosHoy = const [],
    this.co2Hoy = 0,
    this.materialesHoy = 0,
    this.cargando = false,
    this.error,
  });

  double get progreso => (materialesHoy / 20).clamp(0.0, 1.0);

  RecyclingState copyWith({
    List<String>? completadosHoy,
    int? co2Hoy,
    int? materialesHoy,
    bool? cargando,
    String? error,
  }) {
    return RecyclingState(
      completadosHoy: completadosHoy ?? this.completadosHoy,
      co2Hoy: co2Hoy ?? this.co2Hoy,
      materialesHoy: materialesHoy ?? this.materialesHoy,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class RecyclingNotifier extends StateNotifier<RecyclingState> {
  final String _usuarioId;
  final Ref _ref;

  static const Map<String, int> _co2PorSubtipo = {
    'pet_aluminio': 84,
    'cero_desechables': 120,
    'bolsa_reutilizable': 45,
  };

  RecyclingNotifier(this._usuarioId, this._ref) : super(const RecyclingState()) {
    cargarRetosDeHoy();
  }

  Future<void> cargarRetosDeHoy() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final completados = await ApiService.getSubtiposCompletadosHoy(
        usuarioId: _usuarioId,
        tipo: 'reciclaje',
      );

      int co2 = 0;
      for (final subtipo in completados) {
        co2 += _co2PorSubtipo[subtipo] ?? 0;
      }

      state = state.copyWith(
        completadosHoy: completados,
        co2Hoy: co2,
        materialesHoy: completados.length,
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<void> completarReto(String subtipo, {int cantidad = 1}) async {
    if (state.cargando) return;

    final co2Extra = (_co2PorSubtipo[subtipo] ?? 0) * cantidad;
    final nuevosCompletados = List<String>.from(state.completadosHoy);
    for (int i = 0; i < cantidad; i++) {
      nuevosCompletados.add(subtipo);
    }

    state = state.copyWith(
      completadosHoy: nuevosCompletados,
      co2Hoy: state.co2Hoy + co2Extra,
      materialesHoy: state.materialesHoy + cantidad,
    );

    try {
      for (int i = 0; i < cantidad; i++) {
        await ApiService.registrarAccion(
          tipo: 'reciclaje',
          subtipo: subtipo,
          usuarioId: _usuarioId,
        );
      }
      
      _ref.invalidate(impactoGlobalProvider);
      _ref.read(appUserProvider.notifier).fetch(); // Actualizar puntos
      
    } catch (e) {
      cargarRetosDeHoy(); // Revertir cargando de nuevo
      state = state.copyWith(error: e.toString());
    }
  }
}

final recyclingProvider =
StateNotifierProvider.autoDispose<RecyclingNotifier, RecyclingState>((ref) {
  final authUser = ref.watch(authUserProvider);
  return RecyclingNotifier(authUser?.id ?? '', ref);
});
