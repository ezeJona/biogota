import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend-api/api_service.dart';
import '../../text_styles.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpInProcess = useState<bool>(false);
    final signUpSuccessful = useState<bool>(false);
    final error = useState<String>("");

    final TextEditingController emailController = useTextEditingController();
    final TextEditingController password1Controller =
        useTextEditingController();
    final TextEditingController password2Controller =
        useTextEditingController();

    final signUp = useCallback(() async {
      String pw1 = password1Controller.text;
      String pw2 = password2Controller.text;
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
        await ApiService.signUpUser(emailController.text, pw2);
        signUpSuccessful.value = true;
      } catch (e) {
        error.value = "Error al registrarte. Vuelve a intentarlo";
      } finally {
        signUpInProcess.value = false;
      }
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('B I O G O T A')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Crear Cuenta",
                textAlign: TextAlign.center,
                style: BiogotaTextStyle.sectionTitle,
              ),
              const SizedBox(height: 24),
              if (!signUpSuccessful.value) ...[
                TextField(
                  controller: emailController,
                  onChanged: (value) => error.value = "",
                  readOnly: signUpInProcess.value,
                  decoration: const InputDecoration(
                    labelText: "Correo Electrónico",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password1Controller,
                  obscureText: true,
                  readOnly: signUpInProcess.value,
                  onChanged: (value) => error.value = "",
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password2Controller,
                  obscureText: true,
                  readOnly: signUpInProcess.value,
                  onChanged: (value) => error.value = "",
                  decoration: const InputDecoration(
                    labelText: "Repetir Contraseña",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) => signUp(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: signUpInProcess.value ? null : () => signUp(),
                  child: const Text("Regístrate"),
                ),
              ] else ...[
                Text(
                  "Cuenta creada con éxito!\n\nRevisa tu correo electrónico ${emailController.text} y dale clic en el link para activar tu cuenta.\n\nDespués vuelve a la app e inicia sesión.",
                  textAlign: TextAlign.center,
                  style: BiogotaTextStyle.body3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Ir a inicio"),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
