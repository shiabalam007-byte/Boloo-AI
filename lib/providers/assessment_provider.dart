import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'auth_provider.dart';
import 'conversation_provider.dart';
import 'user_provider.dart';

enum AssessmentStatus { idle, active, mayaTyping, scoring, complete, error }

class AssessmentState {
  const AssessmentState({
    this.status = AssessmentStatus.idle,
    this.conversationId,
    this.messages = const [],
    this.userMessageCount = 0,
    this.result,
    this.error,
  });

  final AssessmentStatus status;
  final String? conversationId;
  final List<ChatMessage> messages;
  final int userMessageCount;
  final Map<String, dynamic>? result;
  final String? error;

  // Derived: which question Maya is currently on (0-indexed)
  int get currentQuestionIndex => userMessageCount.clamp(0, 3);

  bool get isComplete => status == AssessmentStatus.complete;
  bool get isMayaTyping => status == AssessmentStatus.mayaTyping;
  bool get isScoring => status == AssessmentStatus.scoring;

  AssessmentState copyWith({
    AssessmentStatus? status,
    String? conversationId,
    List<ChatMessage>? messages,
    int? userMessageCount,
    Map<String, dynamic>? result,
    String? error,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      userMessageCount: userMessageCount ?? this.userMessageCount,
      result: result,
      error: error,
    );
  }
}

final assessmentProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentState>(
  (ref) => AssessmentNotifier(ref),
);

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  AssessmentNotifier(this._ref) : super(const AssessmentState());

  final Ref _ref;
  static const int _totalQuestions = 4;

  Future<void> startAssessment() async {
    // Prevent duplicate starts if already active or complete
    if (state.status != AssessmentStatus.idle && state.status != AssessmentStatus.error) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(status: AssessmentStatus.mayaTyping, error: null);

    try {
      // Create assessment conversation record
      final conversation = await _ref.read(conversationServiceProvider).startSession(
        userId: user.id,
        mode: SessionMode.text,
        sessionType: SessionType.assessment,
        topic: 'Assessment',
        scenario: 'Assessment',
      );

      state = state.copyWith(conversationId: conversation.id);

      // Get Maya's opening message (question 1)
      final profile = _ref.read(userProfileNotifierProvider).value;
      final openingMessage = await _ref.read(mayaServiceProvider).sendAssessmentMessage(
        messages: [],
        languagePreference: profile?.languagePreference.name ?? 'mixed',
        questionIndex: 0,
        userName: profile?.fullName,
      );

      final mayaMsg = await _ref.read(conversationServiceProvider).saveMessage(
        conversationId: conversation.id,
        role: MessageRole.maya,
        content: openingMessage,
      );

      state = state.copyWith(
        status: AssessmentStatus.active,
        messages: [mayaMsg],
      );
    } catch (e) {
      state = state.copyWith(
        status: AssessmentStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> sendAnswer(String content) async {
    final convId = state.conversationId;
    if (convId == null || content.trim().isEmpty) return;
    if (state.status != AssessmentStatus.active) return;

    state = state.copyWith(status: AssessmentStatus.mayaTyping, error: null);

    try {
      // Save user message
      final userMsg = await _ref.read(conversationServiceProvider).saveMessage(
        conversationId: convId,
        role: MessageRole.user,
        content: content.trim(),
      );

      final updatedMessages = [...state.messages, userMsg];
      final newCount = state.userMessageCount + 1;

      state = state.copyWith(
        messages: updatedMessages,
        userMessageCount: newCount,
      );

      final profile = _ref.read(userProfileNotifierProvider).value;

      if (newCount >= _totalQuestions) {
        // This was the last answer — get Maya's closing message then score
        final closingMessage = await _ref.read(mayaServiceProvider).sendAssessmentMessage(
          messages: updatedMessages,
          languagePreference: profile?.languagePreference.name ?? 'mixed',
          questionIndex: 3, // closing prompt
          userName: profile?.fullName,
        );

        final mayaMsg = await _ref.read(conversationServiceProvider).saveMessage(
          conversationId: convId,
          role: MessageRole.maya,
          content: closingMessage,
        );

        state = state.copyWith(
          status: AssessmentStatus.scoring,
          messages: [...updatedMessages, mayaMsg],
        );

        await _scoreAssessment(convId, [...updatedMessages, mayaMsg]);
      } else {
        // Get next question
        final nextIndex = newCount; // 1 answer given → ask question at index 1
        final mayaReply = await _ref.read(mayaServiceProvider).sendAssessmentMessage(
          messages: updatedMessages,
          languagePreference: profile?.languagePreference.name ?? 'mixed',
          questionIndex: nextIndex,
          userName: profile?.fullName,
        );

        final mayaMsg = await _ref.read(conversationServiceProvider).saveMessage(
          conversationId: convId,
          role: MessageRole.maya,
          content: mayaReply,
        );

        state = state.copyWith(
          status: AssessmentStatus.active,
          messages: [...updatedMessages, mayaMsg],
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AssessmentStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> _scoreAssessment(String convId, List<ChatMessage> messages) async {
    try {
      final result = await _ref.read(mayaServiceProvider).scoreAssessment(
        conversationId: convId,
        messages: messages,
      );

      // Validate detected values fall within allowed enums
      final validGoals = {'jobInterview', 'freelancing', 'corporate', 'ielts', 'abroad'};
      final validLevels = {'beginner', 'intermediate', 'upperIntermediate'};

      final detectedGoal = validGoals.contains(result['detected_goal'])
          ? result['detected_goal'] as String
          : 'jobInterview';
      final detectedLevel = validLevels.contains(result['detected_level'])
          ? result['detected_level'] as String
          : 'intermediate';
      final detectedOccupation = result['detected_occupation'] as String? ?? 'Professional';

      // Persist to user profile
      await _ref.read(userProfileNotifierProvider.notifier).completeAssessment(
        assessmentResult: result,
        detectedGoal: detectedGoal,
        detectedLevel: detectedLevel,
        detectedOccupation: detectedOccupation,
      );

      state = state.copyWith(
        status: AssessmentStatus.complete,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: AssessmentStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const AssessmentState();
  }
}
