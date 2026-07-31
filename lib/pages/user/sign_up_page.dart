import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend-api/api_service.dart';
import '../../colors.dart';
import '../../text_styles.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpInProcess = useState<bool>(false);
    final signUpSuccessful = useState<bool>(false);
    final error = useState<String>("");

    final emailController = useTextEditingController();
    final password1Controller = useTextEditingController();
    final password2Controller = useTextEditingController();

    final signUp = useCallback(() async {
      String pw1 = password1Controller.text;
      String pw2 = password2Controller.text;
      if (emailController.text.isEmpty || pw1.isEmpty || pw2.isEmpty) {
        error.value = "Por favor completa todos los campos";
        return;
      }
      if (pw1 != pw2) {
        error.value = "Las contraseñas no coinciden";
        return;
      }
      if (pw1.length < 8) {
        error.value = "La contraseña debe tener mínimo 8 caracteres";
        return;
      }
      try {
        signUpInProcess.value = true;
        await ApiService.signUpUser(emailController.text.trim(), pw2);
        signUpSuccessful.value = true;
      } catch (e) {
        error.value = "Error al registrarte. Vuelve a intentarlo";
      } finally {
        signUpInProcess.value = false;
      }
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Text(
                  "Únete al cambio",
                  style: BiogotaTextStyle.sectionTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 500),
              child: !signUpSuccessful.value ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Crea tu cuenta de Eco-héroe",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: emailController,
                    onChanged: (value) => error.value = "",
                    readOnly: signUpInProcess.value,
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
                    controller: password1Controller,
                    obscureText: true,
                    readOnly: signUpInProcess.value,
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
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: password2Controller,
                    obscureText: true,
                    readOnly: signUpInProcess.value,
                    onChanged: (value) => error.value = "",
                    decoration: InputDecoration(
                      labelText: "Repetir Contraseña",
                      prefixIcon: const Icon(Icons.lock_clock_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) => signUp(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: signUpInProcess.value ? null : () => signUp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: signUpInProcess.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Regístrate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ) : _SuccessView(email: emailController.text),
            ),
            
            if (error.value.isNotEmpty && !signUpSuccessful.value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: BiogotaColors.danger, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        Text(
          "¡Casi listo!",
          style: BiogotaTextStyle.title4,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Hemos enviado un enlace de activación a:\n$email\n\nPor favor, actívalo para empezar tu aventura.",
          textAlign: TextAlign.center,
          style: BiogotaTextStyle.body3.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Volver al inicio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}
