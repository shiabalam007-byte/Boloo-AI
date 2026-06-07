import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curriculum_day.dart';
import '../services/journey_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

final journeyServiceProvider = Provider<JourneyService>((ref) => JourneyService());

final curriculumDaysProvider = FutureProvider<List<CurriculumDay>>((ref) async {
  return ref.watch(journeyServiceProvider).getAllDays();
});

final userJourneyProgressProvider = FutureProvider<Map<int, DayStatus>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(journeyServiceProvider).getUserProgress(user.id);
});

final todaysChallengeProvider = FutureProvider<CurriculumDay?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return null;
  return ref.watch(journeyServiceProvider).getDay(profile.currentDay);
});
