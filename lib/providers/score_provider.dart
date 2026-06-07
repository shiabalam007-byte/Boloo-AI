import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score.dart';
import 'auth_provider.dart';
import 'conversation_provider.dart';

final scoreHistoryProvider = FutureProvider<List<ScoreHistory>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(scoreServiceProvider).getScoreHistory(user.id);
});

final averageScoresProvider = FutureProvider<Map<String, double>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {'confidence': 0, 'fluency': 0, 'communication': 0, 'overall': 0};
  }
  return ref.watch(scoreServiceProvider).getAverageScores(user.id);
});
