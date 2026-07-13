import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/auth_user.dart';
import '../../providers/app_user.dart';
import '../../providers/destroy_session.dart';
import '../../providers/impacto_global_provider.dart';
import '../../backend-api/dtos.dart';
import '../../widgets/biogota_header.dart';
import '../../widgets/biogota_nav_bar.dart';
import '../water/water_page.dart';
import '../recycling/recycling_page.dart';
import '../energy/energy_page.dart';
import '../friends/ranking_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState<bool>(true);
    final isDarkMode = useState<bool>(false);
    final currentNavIndex = useState<int>(2);

    final appUser = ref.watch(appUserProvider);
    final authUser = ref.watch(authUserProvider);

    // Suscripción al Realtime — se actualiza automáticamente
    final impactoAsync = ref.watch(impactoGlobalProvider);

    final fetchAppUser = useCallback(() async {
      if (authUser != null) {
        loading.value = true;
        try {
          final appUserRes = await ref.read(appUserProvider.notifier).fetch();
          if (appUserRes == null) {
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/setup-profile',
                  (route) => false,
            );
          }
        } catch (_) {
        } finally {
          loading.value = false;
        }
      }
    }, [authUser]);

    useEffect(() {
      fetchAppUser();
      return;
    }, [fetchAppUser]);

    if (loading.value && appUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
      isDarkMode.value ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: _buildBody(
        context,
        currentNavIndex.value,
        isDarkMode,
        ref,
        impactoAsync: impactoAsync,
      ),
      bottomNavigationBar: BiogotaNavBar(
        currentIndex: currentNavIndex.value,
        isDarkMode: isDarkMode.value,
        onTap: (index) => currentNavIndex.value = index,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      int index,
      ValueNotifier<bool> isDarkMode,
      WidgetRef ref, {
        required AsyncValue<ImpactoGlobalRes> impactoAsync,
      }) {
    if (index == 0) {
      return WaterPage(
        isDarkMode: isDarkMode.value,
        onThemeToggle: () => isDarkMode.value = !isDarkMode.value,
      );
    } else if (index == 1) {
      return RecyclingPage(
        isDarkMode: isDarkMode.value,
        onThemeToggle: () => isDarkMode.value = !isDarkMode.value,
      );
    } else if (index == 2) {
      return _buildHomeContent(context, isDarkMode, ref,
          impactoAsync: impactoAsync);
    } else if (index == 3) {
      return EnergyPage(
        isDarkMode: isDarkMode.value,
        onThemeToggle: () => isDarkMode.value = !isDarkMode.value,
      );
    } else if (index == 4) {
      return RankingPage(isDarkMode: isDarkMode.value);
    } else {
      return Center(
        child: Text(
          "Página $index en desarrollo",
          style: TextStyle(
              color: isDarkMode.value ? Colors.white : Colors.black),
        ),
      );
    }
  }

  Widget _buildHomeContent(
      BuildContext context,
      ValueNotifier<bool> isDarkMode,
      WidgetRef ref, {
        required AsyncValue<ImpactoGlobalRes> impactoAsync,
      }) {
    final appUser = ref.watch(appUserProvider);
    final isDarkModeVal = isDarkMode.value;
    final primaryTextColor = isDarkModeVal ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkModeVal ? Colors.white70 : Colors.black54;
    final cardColor = isDarkModeVal ? const Color(0xFF1E1E1E) : Colors.white;

    // Extraer datos del stream — mientras carga usa valores vacíos (no bloquea UI)
    final impacto = impactoAsync.valueOrNull ?? ImpactoGlobalRes.empty();

    String formatCarbon(double grams) {
      if (grams < 1000) return "${grams.toStringAsFixed(0)} g";
      return "${(grams / 1000).toStringAsFixed(1)} kg";
    }

    // Equivalencias calculadas dinámicamente
    String equivAgua(double litros) {
      final barriles = (litros / 200).toStringAsFixed(1);
      return "≈ $barriles barriles de agua";
    }

    String equivCarbono(double gramos) {
      final km = (gramos / 150).toStringAsFixed(1);
      return "≈ $km km en auto evitados";
    }

    String equivResiduos(int unidades) {
      return "≈ $unidades piezas fuera del basurero";
    }

    String equivEnergia(double kwh) {
      final cargas = (kwh / 0.012).toStringAsFixed(0);
      return "≈ $cargas cargas de smartphone";
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          BiogotaHeader(
            firstName: appUser?.firstName ?? 'Eco-héroe',
            avatarUrl: appUser?.avatarUrl,
            isDarkMode: isDarkModeVal,
            onThemeToggle: () => isDarkMode.value = !isDarkMode.value,
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Impacto Colectivo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Gráfico de arcos — proporciones relativas al máximo
                Center(
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: ConcentricArcPainter(
                        arcs: [
                          ArcData(
                            _normalizar(impacto.litrosAgua, 10000),
                            Colors.blue,
                            "💧",
                          ),
                          ArcData(
                            _normalizar(impacto.gramosCo2, 50000),
                            Colors.green,
                            "☁️",
                          ),
                          ArcData(
                            _normalizar(
                                impacto.unidadesRecicladas.toDouble(), 500),
                            Colors.orangeAccent,
                            "♻️",
                          ),
                          ArcData(
                            _normalizar(impacto.kwhEnergia, 200),
                            Colors.orange,
                            "⚡",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // CO2 total destacado
                Text(
                  "TOTAL CO₂ EVITADO",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: secondaryTextColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),

                // Indicador de carga en tiempo real
                impactoAsync.isLoading
                    ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : Text(
                  formatCarbon(impacto.gramosCo2),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 32),

                // 4 bloques de impacto
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    ImpactCard(
                      title: "Agua",
                      value: "${impacto.litrosAgua.toStringAsFixed(0)} L",
                      equivalence: equivAgua(impacto.litrosAgua),
                      color: Colors.blue,
                      icon: Icons.water_drop,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Carbono",
                      value: formatCarbon(impacto.gramosCo2),
                      equivalence: equivCarbono(impacto.gramosCo2),
                      color: Colors.green,
                      icon: Icons.cloud,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Residuos",
                      value: "${impacto.unidadesRecicladas} uds",
                      equivalence: equivResiduos(impacto.unidadesRecicladas),
                      color: Colors.orangeAccent,
                      icon: Icons.recycling,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Energía",
                      value:
                      "${impacto.kwhEnergia.toStringAsFixed(1)} kWh",
                      equivalence: equivEnergia(impacto.kwhEnergia),
                      color: Colors.orange,
                      icon: Icons.bolt,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Normaliza un valor entre 0.0 y 1.0 para el gráfico de arcos
  static double _normalizar(double valor, double maximo) {
    if (maximo <= 0) return 0;
    return (valor / maximo).clamp(0.0, 1.0);
  }
}

// ── Clases auxiliares (sin cambios) ──────────────────────────────────────────

class ArcData {
  final double progress;
  final Color color;
  final String icon;
  ArcData(this.progress, this.color, this.icon);
}

class ConcentricArcPainter extends CustomPainter {
  final List<ArcData> arcs;
  ConcentricArcPainter({required this.arcs});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final double maxRadius = size.width * 0.4;
    const double strokeWidth = 14.0;
    const double spacing = 12.0;

    for (int i = 0; i < arcs.length; i++) {
      final radius = maxRadius - (i * (strokeWidth + spacing));

      final bgPaint = Paint()
        ..color = arcs[i].color.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
        false,
        bgPaint,
      );

      final progressPaint = Paint()
        ..color = arcs[i].color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * arcs[i].progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ImpactCard extends StatelessWidget {
  final String title;
  final String value;
  final String equivalence;
  final Color color;
  final IconData icon;
  final Color cardColor;
  final Color textColor;

  const ImpactCard({
    super.key,
    required this.title,
    required this.value,
    required this.equivalence,
    required this.color,
    required this.icon,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Text(
            equivalence,
            style: TextStyle(
              fontSize: 9,
              color: textColor.withOpacity(0.5),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}