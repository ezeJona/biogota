import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/auth_user.dart';
import '../../providers/destroy_session.dart';

class EnergyPage extends HookConsumerWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const EnergyPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final authUser = ref.watch(authUserProvider);

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
    
    // Simulation states
    final energySaved = useState(0.6); // +0.6 kWh
    final completedChallenges = useState(<int>{2}); // "Modo Eco Activo" is completed

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1. HEADER (ZONA DE NAVEGACIÓN)
          BiogotaHeader(
            firstName: "Ahorro de energía",
            subtitle: "Energía",
            userName: fullName,
            email: authUser?.email,
            avatarUrl: appUser?.avatarUrl,
            isDarkMode: isDarkMode,
            onThemeToggle: onThemeToggle,
            customGradient: isDarkMode 
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)] 
                : [const Color(0xFFFFD54F), const Color(0xFFFBC02D)],
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // 2. EL GENERADOR DE IMPACTO (BATERÍA/RAYO VIVO)
                  _EnergyImpactCard(
                    isDarkMode: isDarkMode,
                    progress: 0.6,
                    kWh: energySaved.value,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título de la sección de retos
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        "Retos de hoy",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // 3. EL CATÁLOGO DE RETOS CON INTERRUPTORES
                  _ChallengeSwitchCard(
                    title: "Vampiros Eléctricos",
                    impact: "+0.2 kWh por acción",
                    icon: Icons.power_rounded,
                    isActive: true,
                    isDarkMode: isDarkMode,
                    onChanged: (val) {
                       HapticFeedback.mediumImpact();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ChallengeSwitchCard(
                    title: "Luz Natural",
                    impact: "+0.1 kWh por acción",
                    icon: Icons.wb_sunny_outlined,
                    isActive: false,
                    isDarkMode: isDarkMode,
                    onChanged: (val) {
                       HapticFeedback.lightImpact();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ChallengeSwitchCard(
                    title: "Modo Eco Activo",
                    impact: "Reto ya validado hoy",
                    icon: Icons.eco_outlined,
                    isActive: true,
                    isDarkMode: isDarkMode,
                    isDisabled: true,
                    onChanged: (val) {},
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

class _EnergyImpactCard extends StatelessWidget {
  final bool isDarkMode;
  final double progress;
  final double kWh;

  const _EnergyImpactCard({
    required this.isDarkMode,
    required this.progress,
    required this.kWh,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ILUSTRACIÓN RAYO VIVO
          SizedBox(
            height: 160,
            width: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Brillo de fondo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(80, 120),
                  painter: LightningBoltPainter(
                    progress: progress,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "+${kWh.toStringAsFixed(1)} kWh",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "¡Equivale a cargar 50 smartphones por completo! 📱",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LightningBoltPainter extends CustomPainter {
  final double progress;

  LightningBoltPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFFFE0B2).withOpacity(0.8) // Naranja pastel suave
      ..style = PaintingStyle.fill;

    final path = Path();
    // Forma de rayo estilizada y lineal con bordes suavizados (manual)
    path.moveTo(size.width * 0.65, 0);
    path.lineTo(size.width * 0.25, size.height * 0.52);
    path.lineTo(size.width * 0.52, size.height * 0.52);
    path.lineTo(size.width * 0.35, size.height);
    path.lineTo(size.width * 0.75, size.height * 0.48);
    path.lineTo(size.width * 0.48, size.height * 0.48);
    path.close();

    // Clipping para el progreso de "carga"
    canvas.save();
    canvas.clipPath(path);
    
    // Rellenamos desde abajo según el progreso
    final fillRect = Rect.fromLTRB(
      0, 
      size.height * (1.0 - progress), 
      size.width, 
      size.height
    );
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    // Dibujamos el contorno naranja brillante fino
    canvas.drawPath(path, paint);
    
    // Añadimos un pequeño brillo en la punta superior si está "cargado"
    if (progress > 0.9) {
       final glowPaint = Paint()
        ..color = Colors.orangeAccent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
       canvas.drawCircle(Offset(size.width * 0.65, 0), 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LightningBoltPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ChallengeSwitchCard extends StatelessWidget {
  final String title;
  final String impact;
  final IconData icon;
  final bool isActive;
  final bool isDarkMode;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  const _ChallengeSwitchCard({
    required this.title,
    required this.impact,
    required this.icon,
    required this.isActive,
    required this.isDarkMode,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final accentColor = const Color(0xFFFF9800);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Lado Izquierdo: Contenedor circular e icono
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            
            // Centro: Título e Impacto
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
                    impact,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lado Derecho: Switch o estado bloqueado
            if (isDisabled)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              )
            else
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: isActive,
                  activeColor: accentColor,
                  activeTrackColor: accentColor.withOpacity(0.3),
                  onChanged: onChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
