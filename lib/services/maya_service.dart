import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/curriculum_day.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/logger.dart';

class MayaService {
  final _client = Supabase.instance.client;

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required UserProfile userProfile,
    required CurriculumDay? day,
    String? customTopic,
    String? customScenario,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'maya-conversation',
        body: {
          'messages': messages.map((m) => {
            'role': m.isUser ? 'user' : 'model',
            'content': m.content,
          }).toList(),
          'userContext': {
            'fullName': userProfile.fullName,
            'languagePreference': userProfile.languagePreference.name,
            'primaryGoal': userProfile.primaryGoal?.name ?? 'jobInterview',
            'englishLevel': userProfile.englishLevel?.name ?? 'intermediate',
            'occupation': userProfile.occupation,
            'currentDay': userProfile.currentDay,
          },
          'sessionConfig': {
            'topic': day?.titleEn ?? customTopic ?? 'Free Practice',
            'scenario': day?.scenarioPrompt ?? customScenario ?? 'Have a natural English conversation to practice your communication skills.',
            'sessionType': day != null ? 'daily_challenge' : 'free_practice',
            'keyPhrases': day?.keyPhrases ?? [],
          },
        },
      );

      if (response.data == null) throw ConversationException('No response from Maya');

      final data = response.data as Map<String, dynamic>;
      return data['response'] as String? ?? 'I am here to help you practice. Let us continue!';
    } catch (e) {
      AppLogger.e('MayaService', 'sendMessage failed', e);
      throw ConversationException(e.toString());
    }
  }

  Future<String> sendAssessmentMessage({
    required List<ChatMessage> messages,
    required String languagePreference,
    required int questionIndex,
    String? userName,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'maya-conversation',
        body: {
          'messages': messages.map((m) => {
            'role': m.isUser ? 'user' : 'model',
            'content': m.content,
          }).toList(),
          'userContext': {
            'fullName': userName,
            'languagePreference': languagePreference,
            'primaryGoal': 'jobInterview',
            'englishLevel': 'intermediate',
            'currentDay': 0,
          },
          'sessionConfig': {
            'topic': 'Assessment',
            'scenario': 'Assessment',
            'sessionType': 'assessment',
            'keyPhrases': [],
            'questionIndex': questionIndex,
          },
        },
      );

      if (response.data == null) throw ConversationException('No response from Maya');
      final data = response.data as Map<String, dynamic>;
      return data['response'] as String? ?? 'Tell me more about yourself.';
    } catch (e) {
      AppLogger.e('MayaService', 'sendAssessmentMessage failed', e);
      throw ConversationException(e.toString());
    }
  }

  Future<Map<String, dynamic>> scoreAssessment({
    required String conversationId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final fullTranscript = messages
          .map((m) => '${m.isUser ? 'User' : 'Maya'}: ${m.content}')
          .join('\n\n');

      final userTranscript = messages
          .where((m) => m.isUser)
          .map((m) => m.content)
          .join('\n\n');

      if (userTranscript.trim().isEmpty) return _defaultAssessmentScore();

      final response = await _client.functions.invoke(
        'score-session',
        body: {
          'conversationId': conversationId,
          'transcript': userTranscript,
          'fullTranscript': fullTranscript,
          'userLevel': 'intermediate',
          'languagePreference': 'mixed',
          'topic': 'Assessment',
          'mode': 'assessment',
        },
      );

      if (response.data == null) return _defaultAssessmentScore();
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('MayaService', 'scoreAssessment failed', e);
      return _defaultAssessmentScore();
    }
  }

  Map<String, dynamic> _defaultAssessmentScore() => {
    'confidence_score': 55.0,
    'communication_score': 58.0,
    'overall_score': 57.0,
    'strengths': [
      'You took the first step — that shows real commitment',
      'You expressed your goals clearly',
    ],
    'weaknesses': [
      'Building confidence in professional conversations',
      'Expanding professional vocabulary range',
    ],
    'biggest_opportunity': 'Your career goals are within reach — the right communication skills will unlock the next level.',
    'recommendation': 'Start with 15 minutes of daily practice focused on your specific professional scenarios.',
    'detected_goal': 'jobInterview',
    'detected_level': 'intermediate',
    'detected_occupation': 'Professional',
  };

  Future<Map<String, dynamic>> scoreSession({
    required String conversationId,
    required List<ChatMessage> messages,
    required UserProfile userProfile,
    required String topic,
  }) async {
    try {
      final userMessages = messages
          .where((m) => m.isUser)
          .map((m) => m.content)
          .join('\n\n');

      if (userMessages.trim().isEmpty) {
        return _defaultScore();
      }

      final response = await _client.functions.invoke(
        'score-session',
        body: {
          'conversationId': conversationId,
          'transcript': userMessages,
          'userLevel': userProfile.englishLevel?.name ?? 'intermediate',
          'languagePreference': userProfile.languagePreference.name,
          'topic': topic,
        },
      );

      if (response.data == null) return _defaultScore();
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('MayaService', 'scoreSession failed', e);
      return _defaultScore();
    }
  }

  Map<String, dynamic> _defaultScore() => {
    'confidence_score': 60.0,
    'fluency_score': 60.0,
    'communication_score': 60.0,
    'overall_score': 60.0,
    'strengths': ['You completed a practice session!'],
    'improvements': ['Keep practicing consistently for better scores'],
    'maya_feedback': 'Great effort today! Every session builds your confidence. Keep going!',
  };
}
