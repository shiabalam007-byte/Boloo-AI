import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userServiceProvider).getProfile(user.id);
});

final userProfileNotifierProvider = AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    return ref.watch(userServiceProvider).getProfile(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => future);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updated = await ref.read(userServiceProvider).updateProfile(user.id, updates);
    state = AsyncData(updated);
  }

  Future<void> completeOnboarding({
    required String languagePreference,
    required String primaryGoal,
    required String englishLevel,
    String? occupation,
    required int dailyCommitmentMin,
    String? fullName,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updated = await ref.read(userServiceProvider).completeOnboarding(
      userId: user.id,
      languagePreference: languagePreference,
      primaryGoal: primaryGoal,
      englishLevel: englishLevel,
      occupation: occupation,
      dailyCommitmentMin: dailyCommitmentMin,
      fullName: fullName,
    );
    state = AsyncData(updated);
  }
}
