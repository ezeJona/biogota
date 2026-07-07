import 'package:flutter/material.dart';

class BiogotaHeader extends StatelessWidget {
  final String firstName;
  final String? subtitle;
  final String? avatarUrl;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;

  const BiogotaHeader({
    super.key,
    required this.firstName,
    this.subtitle,
    this.avatarUrl,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [const Color(0xFF5D8BF4), const Color(0xFF4A71D1)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle ?? "Hello!",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                firstName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onThemeToggle,
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'logout') {
                    onLogout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 12),
                        Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
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
