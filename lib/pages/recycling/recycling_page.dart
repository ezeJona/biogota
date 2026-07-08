import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/destroy_session.dart';

class RecyclingPage extends HookConsumerWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const RecyclingPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    
    // States
    final fillPercentage = useState(0.4); // 40% initial
    final co2Avoided = useState(252);
    final materialsCount = useState(3);
    final petCount = useState(3);
    final isDesechablesCompleted = useState(false);

    final greenGradient = isDarkMode 
        ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
        : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          BiogotaHeader(
            firstName: "Reciclaje",
            subtitle: "Impacto",
            avatarUrl: appUser?.avatarUrl,
            isDarkMode: isDarkMode,
            onThemeToggle: onThemeToggle,
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            customGradient: greenGradient,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 2. EL ECO-CONTENEDOR DE IMPACTO DUAL
                  _EcoImpactCard(
                    isDarkMode: isDarkMode,
                    progress: fillPercentage.value,
                    co2: co2Avoided.value,
                    materials: materialsCount.value,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 3. CATÁLOGOS DE RETOS E INCREMENTADORES
                  _IncrementalChallengeCard(
                    title: "PET y Aluminio",
                    subtitle: "+84g CO₂ por pieza",
                    icon: Icons.liquor_rounded,
                    count: petCount.value,
                    isDarkMode: isDarkMode,
                    onIncrement: () => petCount.value++,
                    onDecrement: () => petCount.value = math.max(0, petCount.value - 1),
                    onRegister: () {
                      if (petCount.value > 0) {
                        HapticFeedback.mediumImpact();
                        co2Avoided.value += petCount.value * 84;
                        materialsCount.value += petCount.value;
                        fillPercentage.value = math.min(1.0, fillPercentage.value + (petCount.value * 0.05));
                        petCount.value = 0;
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _QuickActionChallengeCard(
                    title: "Cero Desechables",
                    subtitle: "+120g CO₂",
                    description: "Traje mi termo reutilizable",
                    icon: Icons.eco_rounded,
                    isDarkMode: isDarkMode,
                    isCompleted: isDesechablesCompleted.value,
                    onTap: () {
                      if (!isDesechablesCompleted.value) {
                        HapticFeedback.heavyImpact();
                        isDesechablesCompleted.value = true;
                        co2Avoided.value += 120;
                        materialsCount.value += 1;
                        fillPercentage.value = math.min(1.0, fillPercentage.value + 0.1);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _CompletedChallengeCard(
                    title: "¡Patrulla Limpia completada!",
                    isDarkMode: isDarkMode,
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

class _EcoImpactCard extends StatelessWidget {
  final bool isDarkMode;
  final double progress;
  final int co2;
  final int materials;

  const _EcoImpactCard({
    required this.isDarkMode,
    required this.progress,
    required this.co2,
    required this.materials,
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
          // ILUSTRACIÓN CONTENEDOR ESTILIZADO
          SizedBox(
            height: 140,
            width: 100,
            child: CustomPaint(
              painter: RecyclingContainerPainter(
                fillPercentage: progress,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "+$co2 g CO₂",
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
              "$materials materiales desviados del basurero hoy",
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

class _IncrementalChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;
  final bool isDarkMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRegister;

  const _IncrementalChallengeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.isDarkMode,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF4CAF50);

    return Container(
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
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9), // Soft green/yellow pastel
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.recycling_rounded, color: Color(0xFF8BC34A), size: 28),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryTextColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _RoundButton(icon: Icons.remove, onTap: onDecrement),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  _RoundButton(icon: Icons.add, onTap: onIncrement),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRegister,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Registrar",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool isDarkMode;
  final bool isCompleted;
  final VoidCallback onTap;

  const _QuickActionChallengeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.isDarkMode,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
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
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryTextColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.add_rounded,
                color: isCompleted ? Colors.green : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedChallengeCard extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const _CompletedChallengeCard({
    required this.title,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryTextColor.withOpacity(0.7),
              ),
            ),
            const Icon(Icons.check_circle_outline, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}

class RecyclingContainerPainter extends CustomPainter {
  final double fillPercentage;
  final bool isDarkMode;

  RecyclingContainerPainter({required this.fillPercentage, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = const Color(0xFFA5D6A7).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Trapezoidal bin shape
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Fill
    canvas.save();
    canvas.clipPath(path);
    final fillRect = Rect.fromLTWH(
      0, 
      size.height * (1.0 - fillPercentage), 
      size.width, 
      size.height * fillPercentage
    );
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    // Drawing a simple recycling symbol (triangular arrows)
    final symbolPaint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = 15.0;
    
    // Draw 3 small lines to represent recycling
    for (int i = 0; i < 3; i++) {
      double angle = (i * 120) * math.pi / 180;
      canvas.drawLine(
        Offset(centerX + math.cos(angle) * (radius - 5), centerY + math.sin(angle) * (radius - 5)),
        Offset(centerX + math.cos(angle) * radius, centerY + math.sin(angle) * radius),
        symbolPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant RecyclingContainerPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage;
  }
}
