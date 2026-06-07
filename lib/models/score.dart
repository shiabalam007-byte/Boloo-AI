import 'package:flutter/foundation.dart';

@immutable
class SessionScore {
  const SessionScore({
    required this.confidenceScore,
    required this.fluencyScore,
    required this.communicationScore,
    required this.overallScore,
    required this.strengths,
    required this.improvements,
    required this.mayaFeedback,
  });

  final double confidenceScore;
  final double fluencyScore;
  final double communicationScore;
  final double overallScore;
  final List<String> strengths;
  final List<String> improvements;
  final String mayaFeedback;

  factory SessionScore.fromJson(Map<String, dynamic> json) {
    return SessionScore(
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      fluencyScore: (json['fluency_score'] as num).toDouble(),
      communicationScore: (json['communication_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      strengths: List<String>.from(json['strengths'] as List? ?? []),
      improvements: List<String>.from(json['improvements'] as List? ?? []),
      mayaFeedback: json['maya_feedback'] as String? ?? '',
    );
  }
}

@immutable
class ScoreHistory {
  const ScoreHistory({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.confidenceScore,
    required this.fluencyScore,
    required this.communicationScore,
    required this.overallScore,
    required this.recordedAt,
  });

  final String id;
  final String userId;
  final String conversationId;
  final double confidenceScore;
  final double fluencyScore;
  final double communicationScore;
  final double overallScore;
  final DateTime recordedAt;

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      fluencyScore: (json['fluency_score'] as num).toDouble(),
      communicationScore: (json['communication_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
