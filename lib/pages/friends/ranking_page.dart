import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/app_user.dart';

import '../../providers/ranking_provider.dart';

class RankingPage extends HookConsumerWidget {
  final bool isDarkMode;

  const RankingPage({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final rankingAsync = ref.watch(rankingProvider);
    
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF121212);
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: rankingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error al cargar ranking: $err")),
          data: (ranking) {
            // El podio son los primeros 3
            final podium = ranking.take(3).toList();
            final others = ranking.skip(3).toList();
            
            // Encontrar al usuario actual en el ranking completo para su tarjeta fija
            final currentUserRank = ranking.indexWhere((u) => u.id == appUser?.id);
            final userPosition = currentUserRank != -1 ? ranking[currentUserRank].posicion : 0;
            final userPoints = currentUserRank != -1 ? ranking[currentUserRank].puntos : (appUser?.puntos ?? 0);

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: RefreshIndicator(
                        onRefresh: () => ref.refresh(rankingProvider.future),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              
                              if (podium.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // 2do Lugar
                                      if (podium.length > 1)
                                        _PodiumItem(
                                          rank: 2,
                                          name: podium[1].firstName,
                                          points: podium[1].puntos.toString(),
                                          color: const Color(0xFFC0C0C0),
                                          height: 140,
                                          isDarkMode: isDarkMode,
                                          avatarUrl: podium[1].avatarUrl,
                                        ),
                                      // 1er Lugar
                                      _PodiumItem(
                                        rank: 1,
                                        name: podium[0].firstName,
                                        points: podium[0].puntos.toString(),
                                        color: const Color(0xFFFFD700),
                                        height: 180,
                                        isDarkMode: isDarkMode,
                                        hasCrown: true,
                                        avatarUrl: podium[0].avatarUrl,
                                      ),
                                      // 3er Lugar
                                      if (podium.length > 2)
                                        _PodiumItem(
                                          rank: 3,
                                          name: podium[2].firstName,
                                          points: podium[2].puntos.toString(),
                                          color: const Color(0xFFCD7F32),
                                          height: 120,
                                          isDarkMode: isDarkMode,
                                          avatarUrl: podium[2].avatarUrl,
                                        ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 40),

                              if (others.isNotEmpty)
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
                                    itemCount: others.length,
                                    separatorBuilder: (context, index) => Divider(
                                      color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                                      height: 1,
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    itemBuilder: (context, index) {
                                      final user = others[index];
                                      return _RankListItem(
                                        position: user.posicion,
                                        name: "${user.firstName} ${user.firstLastName}",
                                        degree: "Participante",
                                        points: user.puntos.toString(),
                                        isDarkMode: isDarkMode,
                                        avatarUrl: user.avatarUrl,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
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
                              userPosition > 0 ? "#$userPosition" : "--",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "$userPoints pts",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
  final String? avatarUrl;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.color,
    required this.height,
    required this.isDarkMode,
    this.hasCrown = false,
    this.avatarUrl,
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
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
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
          height: height - 100,
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
  final String? avatarUrl;

  const _RankListItem({
    required this.position,
    required this.name,
    required this.degree,
    required this.points,
    required this.isDarkMode,
    this.avatarUrl,
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
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white70, size: 24)
                : null,
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
