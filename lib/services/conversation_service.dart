import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../core/errors/app_exception.dart';

class ConversationService {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<Conversation> startSession({
    required String userId,
    required SessionMode mode,
    required SessionType sessionType,
    int? journeyDay,
    String? topic,
    String? scenario,
  }) async {
    try {
      final id = _uuid.v4();
      final data = await _client.from('conversations').insert({
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
        'started_at': DateTime.now().toIso8601String(),
      }).select().single();

      return Conversation.fromJson(data);
    } catch (e) {
      throw ConversationException(e.toString());
    }
  }

  Future<ChatMessage> saveMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
    String? audioUrl,
    int? durationMs,
  }) async {
    try {
      final data = await _client.from('messages').insert({
        'id': _uuid.v4(),
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'audio_url': audioUrl,
        'duration_ms': durationMs,
        'word_count': content.split(' ').length,
      }).select().single();

      return ChatMessage.fromJson(data);
    } catch (e) {
      throw ConversationException(e.toString());
    }
  }

  Future<void> endSession({
    required String conversationId,
    required DateTime startedAt,
    required int messageCount,
  }) async {
    final now = DateTime.now();
    final durationSec = now.difference(startedAt).inSeconds;

    await _client.from('conversations').update({
      'ended_at': now.toIso8601String(),
      'duration_sec': durationSec,
      'message_count': messageCount,
    }).eq('id', conversationId);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final profile = await _client
          .from('user_profiles')
          .select('total_sessions, total_minutes')
          .eq('id', userId)
          .single();
      await _client.from('user_profiles').update({
        'total_sessions': ((profile['total_sessions'] as int?) ?? 0) + 1,
        'total_minutes': ((profile['total_minutes'] as int?) ?? 0) +
            (durationSec / 60).ceil(),
      }).eq('id', userId);
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');

    return (data as List).map((m) => ChatMessage.fromJson(m)).toList();
  }

  Future<Conversation> getConversation(String conversationId) async {
    try {
      final data = await _client
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();
      return Conversation.fromJson(data);
    } catch (e) {
      throw ConversationException(e.toString());
    }
  }

  Future<List<Conversation>> getRecentSessions(String userId, {int limit = 10}) async {
    final data = await _client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .not('ended_at', 'is', null)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map((c) => Conversation.fromJson(c)).toList();
  }
}
