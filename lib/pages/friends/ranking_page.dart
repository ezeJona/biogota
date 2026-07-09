import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/app_user.dart';

class RankingPage extends HookConsumerWidget {
  final bool isDarkMode;

  const RankingPage({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF121212);
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tabla de Posiciones",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: primaryTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Feria Comunitaria ECOTON",
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        
                        // 2. EL PÓDIUM DE HONOR
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 2do Lugar
                              _PodiumItem(
                                rank: 2,
                                name: "Ana Silva",
                                points: "1,980",
                                color: const Color(0xFFC0C0C0), // Plateado
                                height: 140,
                                isDarkMode: isDarkMode,
                              ),
                              // 1er Lugar
                              _PodiumItem(
                                rank: 1,
                                name: "Carlos Ruiz",
                                points: "2,500",
                                color: const Color(0xFFFFD700), // Dorado
                                height: 180,
                                isDarkMode: isDarkMode,
                                hasCrown: true,
                              ),
                              // 3er Lugar
                              _PodiumItem(
                                rank: 3,
                                name: "Elena Paz",
                                points: "1,750",
                                color: const Color(0xFFCD7F32), // Bronce
                                height: 120,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 3. LISTA DE COMPETENCIA
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 10,
                            separatorBuilder: (context, index) => Divider(
                              color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            itemBuilder: (context, index) {
                              final position = index + 4;
                              return _RankListItem(
                                position: position,
                                name: "Estudiante ${index + 4}",
                                degree: "Ingeniería Ambiental",
                                points: "${1500 - (index * 80)}",
                                isDarkMode: isDarkMode,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 4. TARJETA FIJA DEL USUARIO (STICKY)
            Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // Azul pastel suave
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Tu posición actual:",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "#24",
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF1976D2),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "850 pts",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final String points;
  final Color color;
  final double height;
  final bool isDarkMode;
  final bool hasCrown;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.color,
    required this.height,
    required this.isDarkMode,
    this.hasCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: rank == 1 ? 90 : 75,
              height: rank == 1 ? 90 : 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
            if (hasCrown)
              const Positioned(
                top: -25,
                child: Text("👑", style: TextStyle(fontSize: 24)),
              ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "#$rank",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: TextStyle(
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          "$points pts",
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: rank == 1 ? 80 : 70,
          height: height - 100, // Altura proporcional
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankListItem extends StatelessWidget {
  final int position;
  final String name;
  final String degree;
  final String points;
  final bool isDarkMode;

  const _RankListItem({
    required this.position,
    required this.name,
    required this.degree,
    required this.points,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "$position",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white54 : Colors.black26,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  degree,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$points pts",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
