import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../colors.dart';
import '../providers/auth_user.dart';

class StartPage extends HookConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkSessionState = useCallback(() async {
      await Future.delayed(const Duration(milliseconds: 3000));
      final authUserRes = ref.read(authUserProvider.notifier).checkSession();
      if (!context.mounted) return;
      if (authUserRes != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }, [context, ref]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkSessionState();
      });
      return;
    }, []);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              BiogotaColors.primary,
              Color(0xFF0a2421), // Tono aún más profundo para el degradado orgánico
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo del colegio
            Image.asset(
              'assets/logo_college.png',
              height: 180,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 40),
            // Texto BIOGOTA
            const Text(
              "BIOGOTA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 10),
            // Subtexto o lema opcional
            Text(
              "MOVILIDAD SOSTENIBLE",
              style: TextStyle(
                color: BiogotaColors.primaryLight.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 60),
            // Indicador de carga sutil
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: BiogotaColors.primaryLight,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
