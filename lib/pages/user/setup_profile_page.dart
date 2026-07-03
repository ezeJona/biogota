import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend-api/api_service.dart';
import '../../backend-api/dtos.dart';
import '../../colors.dart';
import '../../providers/app_user.dart';
import '../../providers/auth_user.dart';
import '../../text_styles.dart';

class SetupProfilePage extends HookConsumerWidget {
  const SetupProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);

    final saving = useState<bool>(false);
    final error = useState<String>("");

    final TextEditingController firstNameController = useTextEditingController();
    final TextEditingController secondNameController = useTextEditingController();
    final TextEditingController firstLastNameController = useTextEditingController();
    final TextEditingController secondLastNameController = useTextEditingController();

    final dateOfBirth = useState<DateTime?>(null);

    Future<void> pickDateOfBirth(BuildContext context) async {
      final now = DateTime.now();
      final initialDate = dateOfBirth.value ?? DateTime(now.year - 18);
      final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: now,
        locale: const Locale('es'),
      );

      if (newDate != null) {
        dateOfBirth.value = newDate;
      }
    }

    final saveProfile = useCallback((BuildContext context) async {
      if (firstNameController.text.isEmpty || firstLastNameController.text.isEmpty) {
        error.value = "Debe ingresar mínimo un nombre y un apellido.";
        return;
      }

      if (authUser != null) {
        saving.value = true;
        error.value = "";
        try {
          final AppUserRes createdUser = await ApiService.createAppUser(
            CreateAppUserReq(
              id: authUser.id,
              firstName: firstNameController.text,
              secondName: secondNameController.text,
              firstLastName: firstLastNameController.text,
              secondLastName: secondLastNameController.text,
              dateOfBirth: dateOfBirth.value,
            ),
          );
          ref.read(appUserProvider.notifier).set(createdUser);
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } catch (err) {
          error.value = err.toString();
        } finally {
          saving.value = false;
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }, [authUser]);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Perfil')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            children: [
              Text("Información Personal", style: BiogotaTextStyle.title4),
              const SizedBox(height: 24),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: "Primer Nombre *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: secondNameController,
                decoration: const InputDecoration(
                  labelText: "Segundo Nombre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: firstLastNameController,
                decoration: const InputDecoration(
                  labelText: "Primer Apellido *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: secondLastNameController,
                decoration: const InputDecoration(
                  labelText: "Segundo Apellido",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => pickDateOfBirth(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Fecha de nacimiento",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    dateOfBirth.value != null
                        ? "${dateOfBirth.value!.day}/${dateOfBirth.value!.month}/${dateOfBirth.value!.year}"
                        : "Seleccionar",
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: saving.value ? null : () => saveProfile(context),
                child: const Text("Guardar y Continuar"),
              ),
              if (error.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    error.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: BiogotaColors.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
