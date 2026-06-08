import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/conversation_provider.dart';
import '../../services/voice_service.dart';

class VoiceSessionScreen extends ConsumerStatefulWidget {
  const VoiceSessionScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<VoiceSessionScreen> createState() => _VoiceSessionScreenState();
}

class _VoiceSessionScreenState extends ConsumerState<VoiceSessionScreen>
    with TickerProviderStateMixin {
  final _voiceService = VoiceService();
  VoiceState _voiceState = VoiceState.idle;
  String _liveTranscript = '';
  bool _sessionEnding = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _voiceService.initialize();
    _voiceService.stateStream.listen((state) {
      if (mounted) setState(() => _voiceState = state);
    });
    _voiceService.transcriptStream.listen((text) {
      if (mounted) setState(() => _liveTranscript = text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialGreeting());
  }

  Future<void> _sendInitialGreeting() async {
    final mayaResponse = await ref
        .read(activeConversationProvider.notifier)
        .sendUserMessage('[SESSION_START]');
    if (mayaResponse != null && mounted) {
      _voiceService.speak(mayaResponse);
    }
  }

  Future<void> _onMicTap() async {
    if (_voiceState == VoiceState.listening) {
      await _voiceService.stopListening();
    } else if (_voiceState == VoiceState.idle) {
      setState(() => _liveTranscript = '');
      await _voiceService.startListening(
        onResult: (text) => _handleUserSpeech(text),
      );
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

    final scores =
        await ref.read(activeConversationProvider.notifier).endSession();
    final convo = ref.read(activeConversationProvider).conversation;
    ref.read(activeConversationProvider.notifier).clearSession();

    if (mounted) {
      context.go('/scorecard', extra: {'scores': scores, 'conversation': convo});
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeConversationProvider);
    final messages = state.messages;

    final lastMayaMessage = messages.any((m) => m.isMaya)
        ? messages.lastWhere((m) => m.isMaya).content
        : null;

    final isSpeaking = _voiceState == VoiceState.speaking;
    final isListening = _voiceState == VoiceState.listening;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(state.conversation?.topic ?? 'Practice Session'),
            Expanded(
              flex: 5,
              child: _buildMayaSection(
                isMayaTyping: state.isMayaTyping,
                isSpeaking: isSpeaking,
                isListening: isListening,
                lastMessage: lastMayaMessage,
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_liveTranscript.isNotEmpty) ...[
                    _buildLiveTranscript(),
                    const SizedBox(height: AppDimensions.lg),
                  ],
                  _buildMicButton(),
                  const SizedBox(height: AppDimensions.md),
                  _buildStatusLabel(),
                ],
              ),
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
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(topic, style: AppTypography.h3),
              ],
            ),
          ),
          TextButton(
            onPressed: _sessionEnding ? null : _endSession,
            child: Text(
              'End',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMayaSection({
    required bool isMayaTyping,
    required bool isSpeaking,
    required bool isListening,
    required String? lastMessage,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Maya avatar with animated state rings
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring when speaking
            if (isSpeaking)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  width: 140 * _pulseAnim.value,
                  height: 140 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.blue.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
            // Listening ring
            if (isListening)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  width: 130 * _pulseAnim.value,
                  height: 130 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            // Maya avatar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSpeaking ? 112 : 100,
              height: isSpeaking ? 112 : 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.brandPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(isSpeaking ? 0.4 : 0.2),
                    blurRadius: isSpeaking ? 32 : 16,
                    spreadRadius: isSpeaking ? 4 : 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),
        if (isMayaTyping)
          _buildTypingIndicator()
        else if (lastMessage != null)
          _buildMayaSpeechBubble(lastMessage),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.mdMinus,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Maya is thinking', style: AppTypography.body),
          SizedBox(width: 8),
          _TypingDots(),
        ],
      ),
    );
  }

  Widget _buildMayaSpeechBubble(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.length > 200 ? '${text.substring(0, 200)}...' : text,
        style: AppTypography.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLiveTranscript() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
      ),
      child: Text(
        _liveTranscript,
        style: AppTypography.body.copyWith(color: AppColors.blue),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMicButton() {
    final isListening = _voiceState == VoiceState.listening;
    final isDisabled = _voiceState == VoiceState.speaking ||
        _voiceState == VoiceState.processing ||
        ref.watch(activeConversationProvider).isMayaTyping;

    return GestureDetector(
      onTap: isDisabled ? null : _onMicTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: isListening ? _pulseAnim.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: AppDimensions.voiceButtonSize * 1.2,
          height: AppDimensions.voiceButtonSize * 1.2,
          decoration: BoxDecoration(
            color: isListening
                ? AppColors.error
                : isDisabled
                    ? AppColors.bgSurface2
                    : AppColors.blue,
            shape: BoxShape.circle,
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: (isListening ? AppColors.error : AppColors.blue)
                          .withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: isListening ? 4 : 0,
                    ),
                  ],
          ),
          child: Icon(
            isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: isDisabled ? AppColors.textTertiary : Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel() {
    final label = switch (_voiceState) {
      VoiceState.listening => 'Listening... tap to stop',
      VoiceState.speaking => 'Maya is speaking...',
      VoiceState.processing => 'Processing...',
      VoiceState.idle => 'Tap to speak',
    };
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        color: _voiceState == VoiceState.listening
            ? AppColors.error
            : AppColors.textTertiary,
      ),
    );
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
      builder: (_, __) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = (t * 3 - i).clamp(0.0, 1.0);
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
        );
      },
    );
  }
}
