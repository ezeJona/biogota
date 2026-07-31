import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend-api/api_service.dart';
import '../../backend-api/dtos.dart';
import '../../colors.dart';
import '../../providers/auth_user.dart';
import '../../text_styles.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con degradado
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_rounded, color: Colors.white, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    "B I O G O T A",
                    style: BiogotaTextStyle.sectionTitle.copyWith(
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tu impacto cuenta",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const _LoginForm(),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends HookConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserNotifier = ref.read(authUserProvider.notifier);
    final loading = useState<bool>(false);
    final error = useState<String>("");

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final login = useCallback((BuildContext context) async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        error.value = "Por favor completa todos los campos";
        return;
      }
      FocusScope.of(context).unfocus();
      loading.value = true;

      try {
        final res = await ApiService.signInUser(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        final authUserRes = AuthUserRes(
          id: res.id,
          email: res.email ?? "${res.id}@biogota.com",
        );
        authUserNotifier.set(authUserRes);
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        error.value = "Correo electrónico o contraseña incorrecta";
      } finally {
        loading.value = false;
      }
    }, []);

    return Container(
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Iniciar Sesión",
            style: BiogotaTextStyle.title4.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: emailController,
            onChanged: (value) => error.value = "",
            readOnly: loading.value,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Correo Electrónico",
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: passwordController,
            obscureText: true,
            readOnly: loading.value,
            onChanged: (value) => error.value = "",
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => login(context),
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: loading.value ? null : () => login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: loading.value 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Ingresar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          if (error.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                error.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: BiogotaColors.danger, fontWeight: FontWeight.w500),
              ),
            ),
            
          const SizedBox(height: 32),
          
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                children: [
                  const TextSpan(text: "¿No tienes cuenta? "),
                  TextSpan(
                    text: "Regístrate aquí",
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).pushNamed('/login/sign-up'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
