import 'dart:convert';
import 'package:http/http.dart' as http;
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
      final session = await _client.auth.getSession();
      final token = session.session?.accessToken;

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
