import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curriculum_day.dart';
import '../core/errors/app_exception.dart';

class JourneyService {
  final _client = Supabase.instance.client;

  Future<List<CurriculumDay>> getAllDays() async {
    final data = await _client
        .from('curriculum_days')
        .select()
        .order('day_number');
    return (data as List).map((d) => CurriculumDay.fromJson(d)).toList();
  }

  Future<CurriculumDay?> getDay(int dayNumber) async {
    try {
      final data = await _client
          .from('curriculum_days')
          .select()
          .eq('day_number', dayNumber)
          .single();
      return CurriculumDay.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<Map<int, DayStatus>> getUserProgress(String userId) async {
    final data = await _client
        .from('user_journey_progress')
        .select()
        .eq('user_id', userId);

    final progress = <int, DayStatus>{};
    for (final row in data as List) {
      final day = row['day_number'] as int;
      final status = row['status'] as String;
      progress[day] = _parseStatus(status);
    }
    return progress;
  }

  Future<void> markDayCompleted({
    required String userId,
    required int dayNumber,
    required String conversationId,
  }) async {
    await _client.from('user_journey_progress').upsert({
      'user_id': userId,
      'day_number': dayNumber,
      'status': 'completed',
      'conversation_id': conversationId,
      'completed_at': DateTime.now().toIso8601String(),
    });

    await _client.from('user_journey_progress').upsert({
      'user_id': userId,
      'day_number': dayNumber + 1,
      'status': 'unlocked',
    });

    await _client.from('user_profiles').update({
      'current_day': dayNumber + 1,
    }).eq('id', userId);
  }

  Future<void> initializeJourney(String userId) async {
    await _client.from('user_journey_progress').upsert({
      'user_id': userId,
      'day_number': 1,
      'status': 'unlocked',
    });
  }

  DayStatus _parseStatus(String s) {
    switch (s) {
      case 'completed': return DayStatus.completed;
      case 'unlocked': return DayStatus.unlocked;
      default: return DayStatus.locked;
    }
  }
}
