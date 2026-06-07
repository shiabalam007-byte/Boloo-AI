import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../core/errors/app_exception.dart';

class UserService {
  final _client = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<UserProfile> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final data = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<UserProfile> completeOnboarding({
    required String userId,
    required String languagePreference,
    required String primaryGoal,
    required String englishLevel,
    required String? occupation,
    required int dailyCommitmentMin,
    String? fullName,
  }) async {
    return updateProfile(userId, {
      'language_preference': languagePreference,
      'primary_goal': primaryGoal,
      'english_level': englishLevel,
      'occupation': occupation,
      'daily_commitment_min': dailyCommitmentMin,
      'onboarding_completed': true,
      if (fullName != null) 'full_name': fullName,
    });
  }
}
