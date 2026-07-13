import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/auth_user.dart';
import '../../providers/destroy_session.dart';
import '../../providers/water_provider.dart';

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
    final authUser = ref.watch(authUserProvider);
    final waterState = ref.watch(waterProvider);
    final waterNotifier = ref.read(waterProvider.notifier);

    final fullName = appUser != null
        ? [
      appUser.firstName,
      if (appUser.secondName != null && appUser.secondName!.isNotEmpty)
        appUser.secondName,
      appUser.firstLastName,
      if (appUser.secondLastName != null && appUser.secondLastName!.isNotEmpty)
        appUser.secondLastName,
    ].join(' ')
        : 'Eco-héroe';

    final backgroundColor =
    isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    final waveController = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    final scrollController = useScrollController();
    final scrollOffset = useState(0.0);

    useEffect(() {
      void listener() => scrollOffset.value = scrollController.offset;
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    // Mostrar error puntual como snackbar sin romper la UI
    ref.listen<WaterState>(waterProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    int countOccurrences(String subtipo) {
      return waterState.completadosHoy.where((s) => s == subtipo).length;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          BiogotaHeader(
            firstName: "Agua",
            subtitle: "Ahorra",
            userName: fullName,
            email: authUser?.email,
            avatarUrl: appUser?.avatarUrl,
            isDarkMode: isDarkMode,
            onThemeToggle: onThemeToggle,
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
          ),
          Expanded(
            child: waterState.cargando && waterState.completadosHoy.isEmpty
            // Solo bloquea la UI en la carga inicial, no en cada acción
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: waveController,
                    builder: (context, child) {
                      return _ImpactTankCard(
                        isDarkMode: isDarkMode,
                        progress: waterState.progreso,
                        litres: waterState.litrosHoy,
                        waveValue: waveController.value,
                        scrollEffect: scrollOffset.value,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _ChallengeCard(
                    id: 0,
                    title: "La Ducha Express",
                    subtitle: "+40 Litros",
                    description:
                    "¿Te bañaste en menos de 5 minutos?",
                    icon: Icons.shower_rounded,
                    impact: 40,
                    isDarkMode: isDarkMode,
                    isCompleted: waterState.completadosHoy
                        .contains('ducha_express'),
                    isRepeatable: false,
                    count: countOccurrences('ducha_express'),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      waterNotifier.completarReto('ducha_express');
                    },
                  ),
                  const SizedBox(height: 16),
                  _ChallengeCard(
                    id: 1,
                    title: "Cierre de Grifo",
                    subtitle: "+5 Litros",
                    description:
                    "Cerré la llave al cepillarme o lavar platos.",
                    icon: Icons.water_damage_rounded,
                    impact: 5,
                    isDarkMode: isDarkMode,
                    isCompleted: waterState.completadosHoy
                        .contains('cierre_grifo'),
                    isRepeatable: true,
                    count: countOccurrences('cierre_grifo'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      waterNotifier.completarReto('cierre_grifo');
                    },
                  ),
                  const SizedBox(height: 16),
                  _ChallengeCard(
                    id: 2,
                    title: "El Guardián del Agua",
                    subtitle: "+20 Litros",
                    description:
                    "Reporté una fuga o cerré llaves en la feria.",
                    icon: Icons.volunteer_activism_rounded,
                    impact: 20,
                    isDarkMode: isDarkMode,
                    isCompleted: waterState.completadosHoy
                        .contains('guardian_agua'),
                    isRepeatable: true,
                    count: countOccurrences('guardian_agua'),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      waterNotifier.completarReto('guardian_agua');
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

// ── Clases auxiliares ─────────────────────────────────────────────────────────

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
              "¡Tu gota del día está al ${(progress * 100).toInt()}%! Completa más retos para llenarla",
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
  final bool isRepeatable;
  final int count;
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
    required this.isRepeatable,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF5D8BF4);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: (isCompleted && !isRepeatable) ? 0.6 : 1.0,
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
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                if (isRepeatable && count > 0)
                  Transform.translate(
                    offset: const Offset(8, -8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 2),
                      ),
                      child: Text(
                        "x$count",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (isCompleted && !isRepeatable) ? null : onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isCompleted && !isRepeatable)
                      ? Colors.green.shade50
                      : accentColor,
                  shape: BoxShape.circle,
                  boxShadow: (isCompleted && !isRepeatable)
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
                  (isCompleted && !isRepeatable) ? Icons.check_rounded : Icons.add_rounded,
                  color: (isCompleted && !isRepeatable) ? Colors.green : Colors.white,
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

    canvas.drawPath(path, paint);
    canvas.save();
    canvas.clipPath(path);

    final wavePath = Path();
    final waveHeight = 6.0;
    final tilt = (scrollOffset / 100).clamp(-0.2, 0.2);
    final yPos = size.height * (1.0 - fillPercentage);

    wavePath.moveTo(0, yPos + (size.width * tilt));
    for (double i = 0; i <= size.width; i++) {
      final wave = math.sin(
          (i / size.width * 2 * math.pi) +
              (waveValue * 2 * math.pi)) *
          waveHeight;
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