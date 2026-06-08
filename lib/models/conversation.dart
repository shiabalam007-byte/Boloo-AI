import 'package:flutter/foundation.dart';

enum SessionMode { voice, text }
enum SessionType { dailyChallenge, freePractice, assessment }

@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.userId,
    required this.mode,
    required this.sessionType,
    this.journeyDay,
    this.topic,
    this.scenario,
    this.startedAt,
    this.endedAt,
    this.durationSec,
    this.messageCount = 0,
    this.confidenceScore,
    this.fluencyScore,
    this.communicationScore,
    this.overallScore,
    this.mayaFeedback,
  });

  final String id;
  final String userId;
  final SessionMode mode;
  final SessionType sessionType;
  final int? journeyDay;
  final String? topic;
  final String? scenario;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSec;
  final int messageCount;
  final double? confidenceScore;
  final double? fluencyScore;
  final double? communicationScore;
  final double? overallScore;
  final String? mayaFeedback;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mode: json['mode'] == 'voice' ? SessionMode.voice : SessionMode.text,
      sessionType: json['session_type'] == 'daily_challenge'
          ? SessionType.dailyChallenge
          : json['session_type'] == 'assessment'
              ? SessionType.assessment
              : SessionType.freePractice,
      journeyDay: json['journey_day'] as int?,
      topic: json['topic'] as String?,
      scenario: json['scenario'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationSec: json['duration_sec'] as int?,
      messageCount: json['message_count'] as int? ?? 0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      fluencyScore: (json['fluency_score'] as num?)?.toDouble(),
      communicationScore: (json['communication_score'] as num?)?.toDouble(),
      overallScore: (json['overall_score'] as num?)?.toDouble(),
      mayaFeedback: json['maya_feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'mode': mode.name,
    'session_type': sessionType == SessionType.dailyChallenge
        ? 'daily_challenge'
        : sessionType == SessionType.assessment
            ? 'assessment'
            : 'free_practice',
    'journey_day': journeyDay,
    'topic': topic,
    'scenario': scenario,
    'started_at': startedAt?.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'duration_sec': durationSec,
    'message_count': messageCount,
    'confidence_score': confidenceScore,
    'fluency_score': fluencyScore,
    'communication_score': communicationScore,
    'overall_score': overallScore,
    'maya_feedback': mayaFeedback,
  };
}
