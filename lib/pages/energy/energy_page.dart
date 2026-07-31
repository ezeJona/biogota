import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/biogota_header.dart';
import '../../providers/app_user.dart';
import '../../providers/auth_user.dart';
import '../../providers/destroy_session.dart';

import '../../providers/energy_provider.dart';

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
    final energyState = ref.watch(energyProvider);
    final energyNotifier = ref.read(energyProvider.notifier);

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

    // Escuchar errores
    ref.listen<EnergyState>(energyProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.redAccent),
        );
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
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
                : [const Color(0xFFE5D200), const Color(0xFFFBC02D)],
            onLogout: () {
              destroySession(ref);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          
          Expanded(
            child: energyState.cargando && energyState.completadosHoy.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _EnergyImpactCard(
                    isDarkMode: isDarkMode,
                    progress: energyState.progreso,
                    kWh: energyState.kwhHoy,
                  ),
                  
                  const SizedBox(height: 32),
                  
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

                  _EnergyChallengeCard(
                    title: "Caza-Vampiros 🧛‍♂️",
                    description: "¡Desconecta todo! Cargadores y aparatos que no uses. Evita el consumo 'vampiro' que chupa energía en silencio.",
                    impact: "+0.2 kWh",
                    icon: Icons.flash_off_rounded,
                    isCompleted: energyState.completadosHoy.contains('vampiros_electricos'),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      energyNotifier.completarReto('vampiros_electricos');
                    },
                  ),
                  const SizedBox(height: 16),
                  _EnergyChallengeCard(
                    title: "Amigo del Sol ☀️",
                    description: "Abre las cortinas y aprovecha la luz natural. Apaga los focos y deja que el sol ilumine tu hogar.",
                    impact: "+0.2 kWh",
                    icon: Icons.wb_sunny_rounded,
                    isCompleted: energyState.completadosHoy.contains('luz_natural'),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      energyNotifier.completarReto('luz_natural');
                    },
                  ),
                  const SizedBox(height: 16),
                  _EnergyChallengeCard(
                    title: "Modo Ninja 🥷",
                    description: "Activa el ahorro de energía en tus dispositivos. ¡Sé eficiente y reduce tu huella eléctrica!",
                    impact: "+0.2 kWh",
                    icon: Icons.visibility_off,
                    isCompleted: energyState.completadosHoy.contains('modo_eco'),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      energyNotifier.completarReto('modo_eco');
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

class _EnergyChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String impact;
  final IconData icon;
  final bool isCompleted;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _EnergyChallengeCard({
    required this.title,
    required this.description,
    required this.impact,
    required this.icon,
    required this.isCompleted,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final accentColor = const Color(0xFFFF9800);

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
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            
            // Texto
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
                      color: secondaryTextColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    impact,
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

            // Botón de Acción
            GestureDetector(
              onTap: isCompleted ? null : onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : accentColor,
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
