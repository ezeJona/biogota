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
}
