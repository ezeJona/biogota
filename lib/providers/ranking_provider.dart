import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../backend-api/api_service.dart';
import '../backend-api/dtos.dart';

final rankingProvider = FutureProvider<List<RankingUserRes>>((ref) async {
  // Podríamos añadir un temporizador para refrescar si fuera necesario
  return await ApiService.getRanking();
});
