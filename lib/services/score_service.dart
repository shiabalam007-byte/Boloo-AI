import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/score.dart';

class ScoreService {
  final _client = Supabase.instance.client;

  Future<List<ScoreHistory>> getScoreHistory(String userId, {int limit = 30}) async {
    try {
      final data = await _client
          .from('score_history')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(limit);

      return (data as List).map((s) => ScoreHistory.fromJson(s)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, double>> getAverageScores(String userId) async {
    final history = await getScoreHistory(userId);
    if (history.isEmpty) {
      return {'confidence': 0, 'fluency': 0, 'communication': 0, 'overall': 0};
    }

    final count = history.length;
    return {
      'confidence': history.map((s) => s.confidenceScore).reduce((a, b) => a + b) / count,
      'fluency': history.map((s) => s.fluencyScore).reduce((a, b) => a + b) / count,
      'communication': history.map((s) => s.communicationScore).reduce((a, b) => a + b) / count,
      'overall': history.map((s) => s.overallScore).reduce((a, b) => a + b) / count,
    };
  }
}
