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

  // Impacto local
  static const double _kwhPorReto = 0.2;
  static const int _co2PorReto = 300;

  // Definir cuáles retos son repetibles (por ahora ninguno en energía)
  static const Set<String> _retosRepetibles = {};

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
        kwhHoy: completados.length * _kwhPorReto,
        co2Hoy: completados.length * _co2PorReto,
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

    state = state.copyWith(
      completadosHoy: [...state.completadosHoy, subtipo],
      kwhHoy: state.kwhHoy + _kwhPorReto,
      co2Hoy: state.co2Hoy + _co2PorReto,
    );

    try {
      await ApiService.registrarAccion(
        tipo: 'energia',
        subtipo: subtipo,
        usuarioId: _usuarioId,
      );
      
      _ref.invalidate(impactoGlobalProvider);
      _ref.read(appUserProvider.notifier).fetch();
      
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('ya la completaste')) {
        // Mantenemos estado ya que el servidor confirma que está hecho
        state = state.copyWith(error: errorMsg);
      } else {
        // Error real, revertir actualización optimista
        final nuevaLista = List<String>.from(state.completadosHoy);
        nuevaLista.remove(subtipo);
        state = state.copyWith(
          completadosHoy: nuevaLista,
          kwhHoy: (state.kwhHoy - _kwhPorReto).clamp(0, 999),
          co2Hoy: (state.co2Hoy - _co2PorReto).clamp(0, 99999),
          error: errorMsg,
        );
      }
    }
  }
}

final energyProvider =
StateNotifierProvider<EnergyNotifier, EnergyState>((ref) {
  final authUser = ref.watch(authUserProvider);
  return EnergyNotifier(authUser?.id ?? '', ref);
});
