import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/destroy_session.dart';

class WaterPage extends HookConsumerWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const WaterPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    
    // Simulation states
    final waterFilledPercentage = useState(0.5); // 50% initial
    final dailyLitres = useState(40);
    final completedChallenges = useState(<int>{2}); // Card 3 (index 2) is completed by today

    // Animation controller for the wave movement
    final waveController = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    // Scroll controller to detect movement
    final scrollController = useScrollController();
    final scrollOffset = useState(0.0);

    useEffect(() {
      void listener() {
        scrollOffset.value = scrollController.offset;
      }
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1. HEADER ESPECIALIZADO
          BiogotaHeader(
            firstName: "Agua",
            subtitle: "Ahorra",
            avatarUrl: appUser?.avatarUrl,
            isDarkMode: isDarkMode,
            onThemeToggle: onThemeToggle,
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 2. TANQUE DE IMPACTO PERSONAL (LA GOTA VIVA)
                  AnimatedBuilder(
                    animation: waveController,
                    builder: (context, child) {
                      return _ImpactTankCard(
                        isDarkMode: isDarkMode,
                        progress: waterFilledPercentage.value,
                        litres: dailyLitres.value,
                        waveValue: waveController.value,
                        scrollEffect: scrollOffset.value,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 3. CATÁLOGO DE RETOS
                  _ChallengeCard(
                    id: 0,
                    title: "La Ducha Express",
                    subtitle: "+40 Litros",
                    description: "¿Te bañaste en menos de 5 minutos?",
                    icon: Icons.shower_rounded,
                    impact: 40,
                    isDarkMode: isDarkMode,
                    isCompleted: completedChallenges.value.contains(0),
                    onTap: () {
                      if (!completedChallenges.value.contains(0)) {
                        HapticFeedback.heavyImpact();
                        completedChallenges.value = {...completedChallenges.value, 0};
                        waterFilledPercentage.value = math.min(1.0, waterFilledPercentage.value + 0.15);
                        dailyLitres.value += 40;
                        // Simulación de sonido de gota:
                        // En un entorno real usaríamos: AudioPlayer().play(AssetSource('sounds/plop.mp3'));
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ChallengeCard(
                    id: 1,
                    title: "Cierre de Grifo",
                    subtitle: "+5 Litros",
                    description: "Cerré la llave al cepillarme o lavar platos.",
                    icon: Icons.water_damage_rounded,
                    impact: 5,
                    isDarkMode: isDarkMode,
                    isCompleted: completedChallenges.value.contains(1),
                    onTap: () {
                      if (!completedChallenges.value.contains(1)) {
                        HapticFeedback.lightImpact();
                        completedChallenges.value = {...completedChallenges.value, 1};
                        waterFilledPercentage.value = math.min(1.0, waterFilledPercentage.value + 0.05);
                        dailyLitres.value += 5;
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ChallengeCard(
                    id: 2,
                    title: "El Guardián del Agua",
                    subtitle: "+20 Litros",
                    description: "Reporté una fuga o cerré llaves en la feria.",
                    icon: Icons.volunteer_activism_rounded,
                    impact: 20,
                    isDarkMode: isDarkMode,
                    isCompleted: completedChallenges.value.contains(2),
                    onTap: () {
                      // Already completed in simulation
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactTankCard extends StatelessWidget {
  final bool isDarkMode;
  final double progress;
  final int litres;
  final double waveValue;
  final double scrollEffect;

  const _ImpactTankCard({
    required this.isDarkMode,
    required this.progress,
    required this.litres,
    required this.waveValue,
    required this.scrollEffect,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // LA GOTA VIVA CON ANIMACIÓN DINÁMICA
          SizedBox(
            height: 160,
            width: 120,
            child: CustomPaint(
              painter: WaterDropPainter(
                fillPercentage: progress,
                borderColor: Colors.blueAccent.shade400,
                waterColor: Colors.blue.shade200,
                waveValue: waveValue,
                scrollOffset: scrollEffect,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "+$litres L",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "¡Tu gota del día está a ${ (progress * 100).toInt()}%! Completa más retos para llenarla",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: primaryTextColor.withOpacity(0.5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final int impact;
  final bool isDarkMode;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.impact,
    required this.isDarkMode,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF5D8BF4);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Lado Izquierdo: Icono minimalista
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Centro: Título y descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryTextColor.withOpacity(0.5),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lado Derecho: Botón de acción
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade50 : accentColor,
                  shape: BoxShape.circle,
                  boxShadow: isCompleted 
                    ? null 
                    : [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.add_rounded,
                  color: isCompleted ? Colors.green : Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final double fillPercentage;
  final Color borderColor;
  final Color waterColor;
  final double waveValue;
  final double scrollOffset;

  WaterDropPainter({
    required this.fillPercentage,
    required this.borderColor,
    required this.waterColor,
    required this.waveValue,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Forma de gota minimalista
    path.moveTo(size.width / 2, 0);
    path.cubicTo(
      size.width * 1.2, size.height * 0.6,
      size.width * 0.9, size.height,
      size.width / 2, size.height,
    );
    path.cubicTo(
      size.width * 0.1, size.height,
      -size.width * 0.2, size.height * 0.6,
      size.width / 2, 0,
    );

    // Dibujar borde
    canvas.drawPath(path, paint);

    // Dibujar relleno dinámico (Clipping para el líquido)
    canvas.save();
    canvas.clipPath(path);
    
    // Simular onda suave en la superficie con animación y efecto de scroll
    final wavePath = Path();
    final waveHeight = 6.0;
    // El scroll inclina ligeramente el agua
    final tilt = (scrollOffset / 100).clamp(-0.2, 0.2);
    final yPos = size.height * (1.0 - fillPercentage);
    
    wavePath.moveTo(0, yPos + (size.width * tilt));
    for (double i = 0; i <= size.width; i++) {
      // Combinamos el tiempo (waveValue) con el movimiento horizontal para la onda
      final wave = math.sin((i / size.width * 2 * math.pi) + (waveValue * 2 * math.pi)) * waveHeight;
      wavePath.lineTo(i, yPos + wave + (i * tilt));
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    
    canvas.drawPath(wavePath, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WaterDropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage || 
           oldDelegate.waveValue != waveValue ||
           oldDelegate.scrollOffset != scrollOffset;
  }
}
