import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../backend-api/api_service.dart';
import '../backend-api/dtos.dart';

// StreamProvider con Polling: Consulta la base de datos cada 5 segundos.
// Esto permite ver cambios de otros usuarios sin necesidad de Supabase Realtime (Replication).
final impactoGlobalProvider = StreamProvider<ImpactoGlobalRes>((ref) async* {
  // Emitir el primer valor inmediatamente
  yield await ApiService.getImpactoGlobal();

  // Crear un stream que emite cada 5 segundos y consulta la base de datos
  yield* Stream.periodic(const Duration(seconds: 5))
      .asyncMap((_) => ApiService.getImpactoGlobal());
});