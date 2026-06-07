import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/conversation_service.dart';
import '../services/maya_service.dart';
import '../services/streak_service.dart';
import '../services/score_service.dart';
import 'auth_provider.dart';

final conversationServiceProvider = Provider<ConversationService>(
  (ref) => ConversationService(),
);
final mayaServiceProvider = Provider<MayaService>((ref) => MayaService());
final streakServiceProvider = Provider<StreakService>((ref) => StreakService());
final scoreServiceProvider = Provider<ScoreService>((ref) => ScoreService());

final activeConversationProvider =
    StateNotifierProvider<ActiveConversationNotifier, ActiveConversationState>(
  (ref) => ActiveConversationNotifier(ref),
);

class ActiveConversationState {
  const ActiveConversationState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isMayaTyping = false,
    this.error,
  });

  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isMayaTyping;
  final String? error;

  ActiveConversationState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isMayaTyping,
    String? error,
  }) {
    return ActiveConversationState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isMayaTyping: isMayaTyping ?? this.isMayaTyping,
      error: error,
    );
  }
}

class ActiveConversationNotifier extends StateNotifier<ActiveConversationState> {
  ActiveConversationNotifier(this._ref) : super(const ActiveConversationState());

  final Ref _ref;

  Future<void> startSession({
    required SessionMode mode,
    required SessionType sessionType,
    int? journeyDay,
    String? topic,
    String? scenario,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final conversation = await _ref.read(conversationServiceProvider).startSession(
        userId: user.id,
        mode: mode,
        sessionType: sessionType,
        journeyDay: journeyDay,
        topic: topic,
        scenario: scenario,
      );

      state = ActiveConversationState(conversation: conversation);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> sendUserMessage(String content) async {
    final convo = state.conversation;
    if (convo == null) return null;

    state = state.copyWith(isMayaTyping: true, error: null);

    try {
      final userMsg = await _ref.read(conversationServiceProvider).saveMessage(
        conversationId: convo.id,
        role: MessageRole.user,
        content: content,
      );

      final updatedMessages = [...state.messages, userMsg];
      state = state.copyWith(messages: updatedMessages);

      final userProfile = await _ref.read(userProfileProvider.future);
      if (userProfile == null) return null;

      final mayaResponse = await _ref.read(mayaServiceProvider).sendMessage(
        messages: updatedMessages,
        userProfile: userProfile,
        day: null,
        customTopic: convo.topic,
        customScenario: convo.scenario,
      );

      final mayaMsg = await _ref.read(conversationServiceProvider).saveMessage(
        conversationId: convo.id,
        role: MessageRole.maya,
        content: mayaResponse,
      );

      state = state.copyWith(
        messages: [...updatedMessages, mayaMsg],
        isMayaTyping: false,
      );

      return mayaResponse;
    } catch (e) {
      state = state.copyWith(isMayaTyping: false, error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> endSession() async {
    final convo = state.conversation;
    if (convo == null) return null;

    try {
      await _ref.read(conversationServiceProvider).endSession(
        conversationId: convo.id,
        startedAt: convo.startedAt ?? DateTime.now(),
        messageCount: state.messages.length,
      );

      final user = _ref.read(currentUserProvider);
      if (user != null) {
        await _ref.read(streakServiceProvider).updateStreak(user.id);
      }

      final userProfile = await _ref.read(userProfileProvider.future);
      if (userProfile != null) {
        final scores = await _ref.read(mayaServiceProvider).scoreSession(
          conversationId: convo.id,
          messages: state.messages,
          userProfile: userProfile,
          topic: convo.topic ?? 'Practice Session',
        );
        return scores;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void clearSession() {
    state = const ActiveConversationState();
  }
}

final recentSessionsProvider = FutureProvider<List<Conversation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(conversationServiceProvider).getRecentSessions(user.id);
});
