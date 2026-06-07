import 'package:flutter/foundation.dart';

@immutable
class Streak {
  const Streak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastPracticeDate,
    required this.totalActiveDays,
  });

  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;
  final int totalActiveDays;

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastPracticeDate: json['last_practice_date'] != null
          ? DateTime.parse(json['last_practice_date'] as String)
          : null,
      totalActiveDays: json['total_active_days'] as int? ?? 0,
    );
  }

  bool get isActiveToday {
    if (lastPracticeDate == null) return false;
    final now = DateTime.now();
    final last = lastPracticeDate!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }
}
