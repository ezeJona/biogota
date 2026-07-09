import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/auth_user.dart';
import '../../providers/app_user.dart';
import '../../providers/destroy_session.dart';
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
    // Hooks for state and UI
    final loading = useState<bool>(true);
    final isDarkMode = useState<bool>(false);
    final currentNavIndex = useState<int>(2); // Inicio por defecto (ahora es el índice 2)

    // Impact simulation values (Simulated real-time data)
    final waterValue = useState(45.0); // Litros
    final carbonValue = useState(12500.0); // Gramos
    final wasteValue = useState(28.0); // Kilogramos
    final energyValue = useState(35.0); // kWh

    // Riverpod providers
    final appUser = ref.watch(appUserProvider);
    final authUser = ref.watch(authUserProvider);

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
        } catch (err) {
          // Error loading profile
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
      backgroundColor: isDarkMode.value ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: _buildBody(
        context, 
        currentNavIndex.value, 
        isDarkMode, 
        ref,
        waterValue: waterValue.value,
        carbonValue: carbonValue.value,
        wasteValue: wasteValue.value,
        energyValue: energyValue.value,
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
    WidgetRef ref,
    {
      required double waterValue,
      required double carbonValue,
      required double wasteValue,
      required double energyValue,
    }
  ) {
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
      return _buildHomeContent(
        context, 
        isDarkMode, 
        ref,
        waterValue: waterValue,
        carbonValue: carbonValue,
        wasteValue: wasteValue,
        energyValue: energyValue,
      );
    } else if (index == 3) {
      return EnergyPage(
        isDarkMode: isDarkMode.value,
        onThemeToggle: () => isDarkMode.value = !isDarkMode.value,
      );
    } else if (index == 4) {
      return RankingPage(
        isDarkMode: isDarkMode.value,
      );
    } else {
      return Center(
        child: Text(
          "Página $index en desarrollo", 
          style: TextStyle(color: isDarkMode.value ? Colors.white : Colors.black)
        )
      );
    }
  }

  Widget _buildHomeContent(
    BuildContext context, 
    ValueNotifier<bool> isDarkMode, 
    WidgetRef ref,
    {
      required double waterValue,
      required double carbonValue,
      required double wasteValue,
      required double energyValue,
    }
  ) {
    final appUser = ref.watch(appUserProvider);
    final isDarkModeVal = isDarkMode.value;
    final primaryTextColor = isDarkModeVal ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkModeVal ? Colors.white70 : Colors.black54;
    final cardColor = isDarkModeVal ? const Color(0xFF1E1E1E) : Colors.white;

    String formatCarbon(double grams) {
      if (grams < 1000) return "${grams.toStringAsFixed(0)} g";
      return "${(grams / 1000).toStringAsFixed(1)} kg";
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                Center(
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: ConcentricArcPainter(
                            arcs: [
                              ArcData(0.85, Colors.blue, "💧"),
                              ArcData(0.65, Colors.green, "☁️"),
                              ArcData(0.45, Colors.orangeAccent, "♻️"),
                              ArcData(0.30, Colors.orange, "⚡"),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 40,
                          child: Row(
                            children: const [
                              Text("💧", style: TextStyle(fontSize: 12)),
                              SizedBox(width: 8),
                              Text("☁️", style: TextStyle(fontSize: 12)),
                              SizedBox(width: 8),
                              Text("♻️", style: TextStyle(fontSize: 12)),
                              SizedBox(width: 8),
                              Text("⚡", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
                Text(
                  formatCarbon(carbonValue),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),
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
                      value: "${waterValue.toInt()} L",
                      equivalence: "Equivale a 3 duchas",
                      color: Colors.blue,
                      icon: Icons.water_drop,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Carbono",
                      value: formatCarbon(carbonValue),
                      equivalence: "50 km en auto evitados",
                      color: Colors.green,
                      icon: Icons.cloud,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Residuos",
                      value: "${wasteValue.toInt()} kg",
                      equivalence: "120 botellas recicladas",
                      color: Colors.orangeAccent,
                      icon: Icons.recycling,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                    ImpactCard(
                      title: "Energía",
                      value: "${energyValue.toInt()} kWh",
                      equivalence: "400 cargas de móvil",
                      color: Colors.orange,
                      icon: Icons.bolt,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Meta Semanal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      WeeklyGoalItem(day: "L", progress: 1.0),
                      WeeklyGoalItem(day: "M", progress: 0.8),
                      WeeklyGoalItem(day: "M", progress: 1.0),
                      WeeklyGoalItem(day: "J", progress: 0.4, isToday: true),
                      WeeklyGoalItem(day: "V", progress: 0.0),
                      WeeklyGoalItem(day: "S", progress: 0.0),
                      WeeklyGoalItem(day: "D", progress: 0.0),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class WeeklyGoalItem extends StatelessWidget {
  final String day;
  final double progress;
  final bool isToday;

  const WeeklyGoalItem({
    super.key,
    required this.day,
    required this.progress,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Colors.blueAccent,
                ),
              ),
            ),
            if (isToday)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
            else
              Text(
                day,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
