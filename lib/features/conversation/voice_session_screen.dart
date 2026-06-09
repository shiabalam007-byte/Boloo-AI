import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/conversation.dart';
import '../../services/voice_service.dart';
import '../../shared/widgets/maya_avatar.dart';

class VoiceSessionScreen extends ConsumerStatefulWidget {
  const VoiceSessionScreen({
    super.key,
    required this.sessionConfig,
  });

  // May contain: topic, scenario, journeyDay, conversationId
  final Map<String, dynamic> sessionConfig;

  @override
  ConsumerState<VoiceSessionScreen> createState() => _VoiceSessionScreenState();
}

class _VoiceSessionScreenState extends ConsumerState<VoiceSessionScreen>
    with TickerProviderStateMixin {
  final _voiceService = VoiceService();
  VoiceState _voiceState = VoiceState.idle;
  String _liveTranscript = '';
  bool _sessionEnding = false;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _voiceService.stateStream.listen((s) {
      if (mounted) setState(() => _voiceState = s);
    });
    _voiceService.transcriptStream.listen((t) {
      if (mounted) setState(() => _liveTranscript = t);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  Future<void> _initSession() async {
    final config = widget.sessionConfig;
    final existingId = config['conversationId'] as String?;

    if (existingId != null) {
      // Resume existing session
      await ref.read(activeConversationProvider.notifier).loadSession(existingId);
    } else {
      // Start new session with config
      final profile = ref.read(userProfileNotifierProvider).value;
      await ref.read(activeConversationProvider.notifier).startSession(
        mode: SessionMode.voice,
        sessionType: SessionType.dailyChallenge,
        journeyDay: config['journeyDay'] as int? ?? (profile?.currentDay ?? 1),
        topic: config['topic'] as String?,
        scenario: config['scenario'] as String?,
      );
    }

    if (!mounted) return;
    setState(() => _sessionStarted = true);
    _sendInitialGreeting();
  }

  Future<void> _sendInitialGreeting() async {
    final response = await ref
        .read(activeConversationProvider.notifier)
        .sendUserMessage('[SESSION_START]');
    if (response != null && mounted) {
      await _voiceService.speak(response);
    }
  }

  Future<void> _onMicTap() async {
    if (_voiceState == VoiceState.listening) {
      await _voiceService.stopListening();
    } else if (_voiceState == VoiceState.idle) {
      setState(() => _liveTranscript = '');
      await _voiceService.startListening(onResult: _handleUserSpeech);
    }
  }

  Future<void> _handleUserSpeech(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _liveTranscript = '');
    final response = await ref
        .read(activeConversationProvider.notifier)
        .sendUserMessage(text);
    if (response != null && mounted) {
      await _voiceService.speak(response);
    }
  }

  Future<void> _endSession() async {
    if (_sessionEnding) return;
    setState(() => _sessionEnding = true);
    await _voiceService.stopSpeaking();
    await _voiceService.stopListening();

    final scores = await ref.read(activeConversationProvider.notifier).endSession();
    final convo = ref.read(activeConversationProvider).conversation;
    ref.read(activeConversationProvider.notifier).clearSession();

    if (mounted) {
      context.go('/scorecard', extra: {'scores': scores, 'conversation': convo});
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeConversationProvider);
    final lastMayaMessage = state.messages.any((m) => m.isMaya)
        ? state.messages.lastWhere((m) => m.isMaya).content
        : null;

    final isSpeaking = _voiceState == VoiceState.speaking;
    final isListening = _voiceState == VoiceState.listening;
    final isProcessing = _voiceState == VoiceState.processing;

    final mayaAvatarState = state.isMayaTyping || isProcessing
        ? MayaState.thinking
        : isSpeaking
            ? MayaState.speaking
            : isListening
                ? MayaState.idle
                : MayaState.idle;

    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(state.conversation?.topic ?? 'Voice Session'),
            Expanded(
              flex: 5,
              child: _buildMayaSection(
                mayaAvatarState: mayaAvatarState,
                isMayaTyping: state.isMayaTyping,
                isSpeaking: isSpeaking,
                lastMessage: lastMayaMessage,
                sessionStarted: _sessionStarted,
              ),
            ),
            // Subtle divider between maya and user sections
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              color: const Color(0xFF1A1A1F),
            ),
            Expanded(
              flex: 4,
              child: _buildUserSection(isListening, isProcessing, state.isMayaTyping),
            ),
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Session',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                Text(
                  topic,
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _sessionEnding ? null : _endSession,
            child: Text(
              'End Session',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMayaSection({
    required MayaState mayaAvatarState,
    required bool isMayaTyping,
    required bool isSpeaking,
    required String? lastMessage,
    required bool sessionStarted,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MayaAvatar(state: mayaAvatarState, size: 140, showLabel: true),
        const SizedBox(height: AppDimensions.lg),
        if (!sessionStarted)
          _buildSpeechBubble('Starting session...')
        else if (isMayaTyping)
          _buildThinkingBubble()
        else if (lastMessage != null)
          _buildSpeechBubble(
            lastMessage.length > 200 ? '${lastMessage.substring(0, 200)}...' : lastMessage,
          ),
      ],
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF2D2D35)),
      ),
      child: Text(
        text,
        style: AppTypography.bodyLarge.copyWith(
          color: Colors.white.withOpacity(0.9),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md, vertical: AppDimensions.mdMinus,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF2D2D35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Maya is thinking',
            style: AppTypography.body.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 8),
          const _TypingDots(),
        ],
      ),
    );
  }

  Widget _buildUserSection(bool isListening, bool isProcessing, bool isMayaTyping) {
    final isDisabled = _voiceState == VoiceState.speaking || isProcessing || isMayaTyping;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_liveTranscript.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md, vertical: AppDimensions.mdMinus,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border(
                left: BorderSide(color: AppColors.blue, width: 4),
              ),
            ),
            child: Text(
              _liveTranscript,
              style: AppTypography.body.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
        // Ambient glow container wrapping the mic button
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: (isListening ? AppColors.error : AppColors.blue)
                          .withOpacity(0.15),
                      blurRadius: 32,
                      spreadRadius: 16,
                    ),
                  ],
          ),
          child: Center(
            child: GestureDetector(
              onTap: isDisabled ? null : _onMicTap,
              child: Container(
                width: AppDimensions.voiceButtonSize * 1.3,
                height: AppDimensions.voiceButtonSize * 1.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppColors.error
                      : isDisabled
                          ? AppColors.bg600
                          : AppColors.blue,
                  boxShadow: isDisabled
                      ? []
                      : [
                          BoxShadow(
                            color: (isListening ? AppColors.error : AppColors.blue)
                                .withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: isListening ? 6 : 2,
                          ),
                        ],
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isDisabled ? AppColors.textTertiary : Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          _voiceLabel(isListening, isProcessing, isMayaTyping),
          style: AppTypography.caption.copyWith(
            color: isListening
                ? AppColors.error
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  String _voiceLabel(bool isListening, bool isProcessing, bool isMayaTyping) {
    if (_voiceState == VoiceState.speaking) return 'Maya is speaking...';
    if (isListening) return 'Listening... tap to stop';
    if (isProcessing) return 'Processing...';
    if (isMayaTyping) return 'Maya is thinking...';
    return 'Tap to speak';
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final opacity = (_controller.value * 3 - i).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
