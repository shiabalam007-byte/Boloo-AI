import 'package:flutter/foundation.dart';

enum MessageRole { user, maya }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.audioUrl,
    this.durationMs,
    this.wordCount,
    this.createdAt,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final String? audioUrl;
  final int? durationMs;
  final int? wordCount;
  final DateTime? createdAt;

  bool get isUser => role == MessageRole.user;
  bool get isMaya => role == MessageRole.maya;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.maya,
      content: json['content'] as String,
      audioUrl: json['audio_url'] as String?,
      durationMs: json['duration_ms'] as int?,
      wordCount: json['word_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'role': role.name,
    'content': content,
    'audio_url': audioUrl,
    'duration_ms': durationMs,
    'word_count': wordCount,
  };
}
