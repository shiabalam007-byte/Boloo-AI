import 'package:flutter/foundation.dart';

enum LanguagePreference { bangla, english, mixed }
enum PrimaryGoal { jobInterview, freelancing, corporate, ielts, abroad }
enum EnglishLevel { beginner, intermediate, upperIntermediate }

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.languagePreference = LanguagePreference.mixed,
    this.primaryGoal,
    this.englishLevel,
    this.occupation,
    this.dailyCommitmentMin = 15,
    this.journeyStartDate,
    this.currentDay = 1,
    this.onboardingCompleted = false,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.createdAt,
  });

  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final LanguagePreference languagePreference;
  final PrimaryGoal? primaryGoal;
  final EnglishLevel? englishLevel;
  final String? occupation;
  final int dailyCommitmentMin;
  final DateTime? journeyStartDate;
  final int currentDay;
  final bool onboardingCompleted;
  final int totalSessions;
  final int totalMinutes;
  final DateTime? createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      languagePreference: _langFromString(json['language_preference'] as String?),
      primaryGoal: _goalFromString(json['primary_goal'] as String?),
      englishLevel: _levelFromString(json['english_level'] as String?),
      occupation: json['occupation'] as String?,
      dailyCommitmentMin: json['daily_commitment_min'] as int? ?? 15,
      journeyStartDate: json['journey_start_date'] != null
          ? DateTime.parse(json['journey_start_date'] as String)
          : null,
      currentDay: json['current_day'] as int? ?? 1,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'phone': phone,
    'language_preference': languagePreference.name,
    'primary_goal': primaryGoal?.name,
    'english_level': englishLevel?.name,
    'occupation': occupation,
    'daily_commitment_min': dailyCommitmentMin,
    'journey_start_date': journeyStartDate?.toIso8601String().split('T').first,
    'current_day': currentDay,
    'onboarding_completed': onboardingCompleted,
    'total_sessions': totalSessions,
    'total_minutes': totalMinutes,
  };

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    LanguagePreference? languagePreference,
    PrimaryGoal? primaryGoal,
    EnglishLevel? englishLevel,
    String? occupation,
    int? dailyCommitmentMin,
    DateTime? journeyStartDate,
    int? currentDay,
    bool? onboardingCompleted,
    int? totalSessions,
    int? totalMinutes,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      languagePreference: languagePreference ?? this.languagePreference,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      englishLevel: englishLevel ?? this.englishLevel,
      occupation: occupation ?? this.occupation,
      dailyCommitmentMin: dailyCommitmentMin ?? this.dailyCommitmentMin,
      journeyStartDate: journeyStartDate ?? this.journeyStartDate,
      currentDay: currentDay ?? this.currentDay,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      createdAt: createdAt,
    );
  }

  static LanguagePreference _langFromString(String? s) {
    switch (s) {
      case 'bangla': return LanguagePreference.bangla;
      case 'english': return LanguagePreference.english;
      default: return LanguagePreference.mixed;
    }
  }

  static PrimaryGoal? _goalFromString(String? s) {
    switch (s) {
      case 'jobInterview': return PrimaryGoal.jobInterview;
      case 'freelancing': return PrimaryGoal.freelancing;
      case 'corporate': return PrimaryGoal.corporate;
      case 'ielts': return PrimaryGoal.ielts;
      case 'abroad': return PrimaryGoal.abroad;
      default: return null;
    }
  }

  static EnglishLevel? _levelFromString(String? s) {
    switch (s) {
      case 'beginner': return EnglishLevel.beginner;
      case 'intermediate': return EnglishLevel.intermediate;
      case 'upperIntermediate': return EnglishLevel.upperIntermediate;
      default: return null;
    }
  }
}
