import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak.dart';
import 'auth_provider.dart';
import 'conversation_provider.dart';

final streakProvider = FutureProvider<Streak?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(streakServiceProvider).getStreak(user.id);
});
