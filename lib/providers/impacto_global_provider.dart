import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../backend-api/api_service.dart';
import '../backend-api/dtos.dart';

// StreamProvider: se suscribe al Realtime de Supabase automáticamente
final impactoGlobalProvider = StreamProvider<ImpactoGlobalRes>((ref) {
  return ApiService.suscribirImpactoGlobal();
});