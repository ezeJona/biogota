import 'package:supabase_flutter/supabase_flutter.dart';

import 'dtos.dart';

// All API functions to make requests to the supabase backend go here
class ApiService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static AuthUserRes? checkAndGetUserSession() {
    try {
      final User? authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        return AuthUserRes(
          id: authUser.id,
          email: authUser.email ?? "${authUser.id}@biogota.com",
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to check user session: $e');
    }
  }

  static Future<AppUserRes> createAppUser(CreateAppUserReq req) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from('app_users')
          .insert(req.toJson())
          .select()
          .single();
      return AppUserRes.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create app user: $e');
    }
  }

  static Future<AppUserRes?> getAppUser(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from('app_users')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        return AppUserRes.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch app user: $e');
    }
  }

  static Future<User> signInUser(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user!;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  static Future<void> signOutUser() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  static Future<void> signUpUser(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'biogota://login-callback',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Carga inicial del contador global
  static Future<ImpactoGlobalRes> getImpactoGlobal() async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from('impacto_global')
          .select()
          .eq('id', 1)
          .single();
      return ImpactoGlobalRes.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener impacto global: $e');
    }
  }

// Stream de Realtime — emite cada vez que cambia impacto_global
  static Stream<ImpactoGlobalRes> suscribirImpactoGlobal() {
    return _supabase
        .from('impacto_global')
        .stream(primaryKey: ['id'])
        .eq('id', 1)
        .map((rows) => ImpactoGlobalRes.fromJson(rows.first));
  }


  // Llama a la función de Supabase que valida, registra y acumula
  static Future<void> registrarAccion({
    required String tipo,
    required String subtipo,
    required String usuarioId,
  }) async {
    try {
      await _supabase.rpc('registrar_accion', params: {
        'p_tipo': tipo,
        'p_subtipo': subtipo,
        'p_usuario_id': usuarioId,
      });
    } on PostgrestException catch (e) {
      // La función lanza EXCEPTION si el reto ya fue completado hoy
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrar acción: $e');
    }
  }

// Devuelve los subtipos que el usuario ya completó hoy
  static Future<List<String>> getSubtiposCompletadosHoy({
    required String usuarioId,
    required String tipo,
  }) async {
    try {
      final hoy = DateTime.now();
      final desde = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
      final hasta = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();

      final List<dynamic> response = await _supabase
          .from('acciones_usuarios')
          .select('subtipo_accion')
          .eq('usuario_id', usuarioId)
          .eq('tipo_accion', tipo)
          .gte('registrado_en', desde)
          .lte('registrado_en', hasta);

      return response
          .map((e) => e['subtipo_accion'] as String?)
          .whereType<String>()
          .toList();
    } catch (e) {
      throw Exception('Error al consultar retos de hoy: $e');
    }
  }
}
