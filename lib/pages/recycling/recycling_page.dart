import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/auth_user.dart';
import '../../providers/destroy_session.dart';

import '../../providers/recycling_provider.dart';

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
    final authUser = ref.watch(authUserProvider);
    final recyclingState = ref.watch(recyclingProvider);
    final recyclingNotifier = ref.read(recyclingProvider.notifier);

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

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    
    // States locales para el contador antes de registrar
    final petCount = useState(0);

    // Escuchar errores
    ref.listen<RecyclingState>(recyclingProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.redAccent),
        );
      }
    });

    final greenGradient = isDarkMode 
        ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
        : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];

    int countOccurrences(String subtipo) {
      return recyclingState.completadosHoy.where((s) => s == subtipo).length;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          BiogotaHeader(
            firstName: "Reciclaje",
            subtitle: "Impacto",
            userName: fullName,
            email: authUser?.email,
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
                  if (recyclingState.cargando && recyclingState.completadosHoy.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: CircularProgressIndicator(),
                    ),
                  _EcoImpactCard(
                    isDarkMode: isDarkMode,
                    progress: recyclingState.progreso,
                    co2: recyclingState.co2Hoy,
                    materials: recyclingState.materialesHoy,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _IncrementalChallengeCard(
                    title: "Cazador de Tesoros 💎",
                    subtitle: "+84g CO₂ por pieza",
                    description: "¡Encuentra y recicla botellas, latas o papel! Cada objeto cuenta para limpiar nuestro entorno.",
                    icon: Icons.auto_awesome_rounded,
                    count: petCount.value,
                    registeredCount: countOccurrences('pet_aluminio'),
                    isDarkMode: isDarkMode,
                    onIncrement: () => petCount.value++,
                    onDecrement: () => petCount.value = math.max(0, petCount.value - 1),
                    onRegister: () {
                      if (petCount.value > 0) {
                        HapticFeedback.mediumImpact();
                        recyclingNotifier.completarReto('pet_aluminio', cantidad: petCount.value);
                        petCount.value = 0;
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _QuickActionChallengeCard(
                    title: "Mi Super-Termo 🥤",
                    subtitle: "+120g CO₂",
                    description: "¡Lleva tu termo siempre contigo y evita usar vasos desechables!",
                    icon: Icons.local_drink_rounded,
                    isDarkMode: isDarkMode,
                    isCompleted: recyclingState.completadosHoy.contains('cero_desechables'),
                    isRepeatable: false,
                    count: countOccurrences('cero_desechables'),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      recyclingNotifier.completarReto('cero_desechables');
                    },
                  ),

                  const SizedBox(height: 16),

                  _QuickActionChallengeCard(
                    title: "Bolsa Infinita 🛍️",
                    subtitle: "+45g CO₂",
                    description: "¡Usa tu bolsa de tela o carrito y evita el plástico al comprar!",
                    icon: Icons.shopping_bag_rounded,
                    isDarkMode: isDarkMode,
                    isCompleted: recyclingState.completadosHoy.contains('bolsa_reutilizable'),
                    isRepeatable: false,
                    count: countOccurrences('bolsa_reutilizable'),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      recyclingNotifier.completarReto('bolsa_reutilizable');
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
  final String description;
  final IconData icon;
  final int count;
  final int registeredCount;
  final bool isDarkMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRegister;

  const _IncrementalChallengeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.count,
    required this.registeredCount,
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9), 
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.recycling_rounded, color: Color(0xFF8BC34A), size: 28),
              ),
              if (registeredCount > 0)
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
                      "x$registeredCount",
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
  final bool isRepeatable;
  final int count;
  final VoidCallback onTap;

  const _QuickActionChallengeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
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
    final accentColor = const Color(0xFF4CAF50);

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
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (isCompleted && !isRepeatable) ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isCompleted && !isRepeatable) ? Colors.green.shade50 : accentColor,
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
