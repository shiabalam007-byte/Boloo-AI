import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/streak.dart';

class StreakService {
  final _client = Supabase.instance.client;

  Future<Streak?> getStreak(String userId) async {
    try {
      final data = await _client
          .from('streaks')
          .select()
          .eq('user_id', userId)
          .single();
      return Streak.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<Streak> updateStreak(String userId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final current = await getStreak(userId);

    if (current == null) {
      final data = await _client.from('streaks').insert({
        'user_id': userId,
        'current_streak': 1,
        'longest_streak': 1,
        'last_practice_date': todayDate.toIso8601String().split('T').first,
        'total_active_days': 1,
      }).select().single();
      return Streak.fromJson(data);
    }

    if (current.isActiveToday) return current;

    final lastDate = current.lastPracticeDate;
    final isYesterday = lastDate != null &&
        todayDate.difference(lastDate).inDays == 1;

    final newStreak = isYesterday ? current.currentStreak + 1 : 1;
    final newLongest = newStreak > current.longestStreak
        ? newStreak
        : current.longestStreak;

    final data = await _client.from('streaks').update({
      'current_streak': newStreak,
      'longest_streak': newLongest,
      'last_practice_date': todayDate.toIso8601String().split('T').first,
      'total_active_days': current.totalActiveDays + 1,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId).select().single();

    return Streak.fromJson(data);
  }
}
