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

    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final firstLastNameController = useTextEditingController();
    final secondLastNameController = useTextEditingController();
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
      if (newDate != null) dateOfBirth.value = newDate;
    }

    final saveProfile = useCallback((BuildContext context) async {
      if (firstNameController.text.isEmpty || firstLastNameController.text.isEmpty) {
        error.value = "Nombre y primer apellido son obligatorios.";
        return;
      }

      if (authUser != null) {
        saving.value = true;
        error.value = "";
        try {
          final AppUserRes createdUser = await ApiService.createAppUser(
            CreateAppUserReq(
              id: authUser.id,
              firstName: firstNameController.text.trim(),
              secondName: secondNameController.text.trim(),
              firstLastName: firstLastNameController.text.trim(),
              secondLastName: secondLastNameController.text.trim(),
              dateOfBirth: dateOfBirth.value,
            ),
          );
          ref.read(appUserProvider.notifier).set(createdUser);
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } catch (err) {
          error.value = "Error al guardar el perfil. Intenta de nuevo.";
        } finally {
          saving.value = false;
        }
      }
    }, [authUser, dateOfBirth.value]);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF00695C),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Configura tu Perfil",
                style: BiogotaTextStyle.title4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Icon(
                        Icons.person_add_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_circle_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "¡Bienvenido, Eco-héroe!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _ProfileFormCard(
                    firstNameController: firstNameController,
                    secondNameController: secondNameController,
                    firstLastNameController: firstLastNameController,
                    secondLastNameController: secondLastNameController,
                    dateOfBirth: dateOfBirth.value,
                    onPickDate: () => pickDateOfBirth(context),
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving.value ? null : () => saveProfile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00695C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: saving.value 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Completar Perfil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  if (error.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(error.value, style: const TextStyle(color: BiogotaColors.danger)),
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

class _ProfileFormCard extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController firstLastNameController;
  final TextEditingController secondLastNameController;
  final DateTime? dateOfBirth;
  final VoidCallback onPickDate;

  const _ProfileFormCard({
    required this.firstNameController,
    required this.secondNameController,
    required this.firstLastNameController,
    required this.secondLastNameController,
    required this.dateOfBirth,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Datos Personales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
          const SizedBox(height: 24),
          _buildField(firstNameController, "Primer Nombre *", Icons.person_outline),
          const SizedBox(height: 16),
          _buildField(secondNameController, "Segundo Nombre", Icons.person_outline),
          const SizedBox(height: 16),
          _buildField(firstLastNameController, "Primer Apellido *", Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildField(secondLastNameController, "Segundo Apellido", Icons.badge_outlined),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "Fecha de Nacimiento",
                prefixIcon: const Icon(Icons.calendar_today_rounded),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              child: Text(
                dateOfBirth != null ? "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}" : "Seleccionar fecha",
                style: TextStyle(color: dateOfBirth != null ? Colors.black87 : Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
