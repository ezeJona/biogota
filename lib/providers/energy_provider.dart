import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../backend-api/api_service.dart';
import 'auth_user.dart';
import 'app_user.dart';
import 'impacto_global_provider.dart';

class EnergyState {
  final List<String> completadosHoy;
  final double kwhHoy;
  final int co2Hoy;
  final bool cargando;
  final String? error;

  const EnergyState({
    this.completadosHoy = const [],
    this.kwhHoy = 0.0,
    this.co2Hoy = 0,
    this.cargando = false,
    this.error,
  });

  double get progreso => (kwhHoy / 2.0).clamp(0.0, 1.0);

  EnergyState copyWith({
    List<String>? completadosHoy,
    double? kwhHoy,
    int? co2Hoy,
    bool? cargando,
    String? error,
  }) {
    return EnergyState(
      completadosHoy: completadosHoy ?? this.completadosHoy,
      kwhHoy: kwhHoy ?? this.kwhHoy,
      co2Hoy: co2Hoy ?? this.co2Hoy,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class EnergyNotifier extends StateNotifier<EnergyState> {
  final String _usuarioId;
  final Ref _ref;

  EnergyNotifier(this._usuarioId, this._ref) : super(const EnergyState()) {
    cargarRetosDeHoy();
  }

  Future<void> cargarRetosDeHoy() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final completados = await ApiService.getSubtiposCompletadosHoy(
        usuarioId: _usuarioId,
        tipo: 'energia',
      );

      state = state.copyWith(
        completadosHoy: completados,
        kwhHoy: completados.length * 0.2,
        co2Hoy: completados.length * 300,
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<void> completarReto(String subtipo) async {
    if (state.cargando) return;

    state = state.copyWith(
      completadosHoy: [...state.completadosHoy, subtipo],
      kwhHoy: state.kwhHoy + 0.2,
      co2Hoy: state.co2Hoy + 300,
    );

    try {
      await ApiService.registrarAccion(
        tipo: 'energia',
        subtipo: subtipo,
        usuarioId: _usuarioId,
      );
      
      _ref.invalidate(impactoGlobalProvider);
      _ref.read(appUserProvider.notifier).fetch(); // Actualizar puntos
      
    } catch (e) {
      cargarRetosDeHoy();
      state = state.copyWith(error: e.toString());
    }
  }
}

final energyProvider =
StateNotifierProvider.autoDispose<EnergyNotifier, EnergyState>((ref) {
  final authUser = ref.watch(authUserProvider);
  return EnergyNotifier(authUser?.id ?? '', ref);
});
