import 'package:flutter/foundation.dart';

@immutable
class CurriculumDay {
  const CurriculumDay({
    required this.dayNumber,
    required this.weekNumber,
    required this.phase,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.scenarioType,
    required this.scenarioPrompt,
    required this.learningObjectives,
    required this.keyPhrases,
    required this.difficulty,
    required this.estimatedMin,
    this.isMilestone = false,
  });

  final int dayNumber;
  final int weekNumber;
  final String phase;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final String scenarioType;
  final String scenarioPrompt;
  final List<String> learningObjectives;
  final List<String> keyPhrases;
  final int difficulty;
  final int estimatedMin;
  final bool isMilestone;

  factory CurriculumDay.fromJson(Map<String, dynamic> json) {
    return CurriculumDay(
      dayNumber: json['day_number'] as int,
      weekNumber: json['week_number'] as int,
      phase: json['phase'] as String,
      titleEn: json['title_en'] as String,
      titleBn: json['title_bn'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionBn: json['description_bn'] as String,
      scenarioType: json['scenario_type'] as String,
      scenarioPrompt: json['scenario_prompt'] as String,
      learningObjectives: List<String>.from(json['learning_objectives'] as List? ?? []),
      keyPhrases: List<String>.from(json['key_phrases'] as List? ?? []),
      difficulty: json['difficulty'] as int,
      estimatedMin: json['estimated_min'] as int? ?? 15,
      isMilestone: json['is_milestone'] as bool? ?? false,
    );
  }
}

enum DayStatus { locked, unlocked, completed }
