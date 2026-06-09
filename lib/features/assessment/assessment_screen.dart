import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/assessment_provider.dart';
import '../../services/voice_service.dart';
import '../../shared/widgets/maya_avatar.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final _voiceService = VoiceService();
  final _textController = TextEditingController();
  VoiceState _voiceState = VoiceState.idle;
  String _liveTranscript = '';
  bool _showFallbackInput = false;
  String? _lastSpokenMessage;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _voiceService.stateStream.listen((state) {
      if (mounted) setState(() => _voiceState = state);
    });
    _voiceService.transcriptStream.listen((text) {
      if (mounted) setState(() => _liveTranscript = text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assessmentProvider.notifier).startAssessment();
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onAssessmentStateChanged(AssessmentState? prev, AssessmentState next) {
    if (next.status == AssessmentStatus.complete && next.result != null) {
      context.go('/assessment-result');
      return;
    }

    if (next.messages.isEmpty) return;
    final lastMessage = next.messages.last;
    if (!lastMessage.isMaya) return;

    final content = lastMessage.content;
    if (content == _lastSpokenMessage) return;
    if (next.status == AssessmentStatus.mayaTyping) return;

    _lastSpokenMessage = content;
    _speakAndListen(content);
  }

  Future<void> _speakAndListen(String text) async {
    await _voiceService.speak(text);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final state = ref.read(assessmentProvider);
    if (state.status == AssessmentStatus.active && _voiceState == VoiceState.idle) {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() => _liveTranscript = '');
    await _voiceService.startListening(
      onResult: (text) => _submitAnswer(text),
    );
  }

  Future<void> _onMicTap() async {
    if (_voiceState == VoiceState.listening) {
      await _voiceService.stopListening();
    } else if (_voiceState == VoiceState.idle) {
      _startListening();
    }
  }

  Future<void> _submitAnswer(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _liveTranscript = '');
    await ref.read(assessmentProvider.notifier).sendAnswer(text.trim());
  }

  Future<void> _submitTextAnswer() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    FocusScope.of(context).unfocus();
    await _submitAnswer(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);

    ref.listen(assessmentProvider, _onAssessmentStateChanged);

    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(state),
            Expanded(child: _buildBody(state)),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AssessmentState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.md, AppDimensions.lg, 0,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/auth'),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),
          const Spacer(),
          if (state.status != AssessmentStatus.scoring &&
              state.status != AssessmentStatus.complete)
            _ProgressDots(
              current: state.userMessageCount,
              total: 4,
            ),
          const SizedBox(width: AppDimensions.sm),
          GestureDetector(
            onTap: () => setState(() => _showFallbackInput = !_showFallbackInput),
            child: Icon(
              Icons.keyboard_rounded,
              color: _showFallbackInput
                  ? AppColors.blue
                  : Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AssessmentState state) {
    if (state.status == AssessmentStatus.error) {
      return _buildErrorState(state);
    }

    if (state.status == AssessmentStatus.scoring) {
      return _buildScoringState();
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: _buildMayaSection(state),
        ),
        // Subtle dark divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          color: const Color(0xFF1A1A1F),
        ),
        Expanded(
          flex: 4,
          child: _buildUserSection(state),
        ),
      ],
    );
  }

  Widget _buildMayaSection(AssessmentState state) {
    final isThinking = state.status == AssessmentStatus.mayaTyping;
    final isSpeaking = _voiceState == VoiceState.speaking;

    final mayaAvatarState = isThinking
        ? MayaState.thinking
        : isSpeaking
            ? MayaState.speaking
            : MayaState.idle;

    final lastMayaMessage = state.messages.any((m) => m.isMaya)
        ? state.messages.lastWhere((m) => m.isMaya).content
        : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MayaAvatar(state: mayaAvatarState, size: 130, showLabel: true),
        const SizedBox(height: AppDimensions.lg),
        if (isThinking)
          _DarkThinkingBubble()
        else if (lastMayaMessage != null)
          _DarkSpeechBubble(text: lastMayaMessage)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Text(
              'Maya is getting ready for you...',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildUserSection(AssessmentState state) {
    final isActive = state.status == AssessmentStatus.active;
    final isListening = _voiceState == VoiceState.listening;
    final isDisabled = !isActive || _voiceState == VoiceState.speaking;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_liveTranscript.isNotEmpty) ...[
          _DarkTranscriptBubble(text: _liveTranscript),
          const SizedBox(height: AppDimensions.md),
        ],
        if (!_showFallbackInput) ...[
          // Ambient glow container — mirrors Voice Session
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
              child: _DarkMicButton(
                isListening: isListening,
                isDisabled: isDisabled,
                onTap: isDisabled ? null : _onMicTap,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            _statusLabel(state, isListening),
            style: AppTypography.caption.copyWith(
              color: isListening
                  ? AppColors.error
                  : Colors.white.withOpacity(0.45),
            ),
          ),
        ] else ...[
          _DarkFallbackInput(
            controller: _textController,
            enabled: isActive,
            onSubmit: _submitTextAnswer,
          ),
        ],
      ],
    );
  }

  Widget _buildScoringState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MayaAvatar(state: MayaState.thinking, size: 120, showLabel: true),
        const SizedBox(height: AppDimensions.xl),
        Text(
          'Building your personalized plan...',
          style: AppTypography.h2.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Maya is analyzing your responses.',
          style: AppTypography.body.copyWith(color: Colors.white.withOpacity(0.5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xl),
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AssessmentState state) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MayaAvatar(state: MayaState.idle, size: 100, showLabel: true),
          const SizedBox(height: AppDimensions.xl),
          Text(
            'Could not reach Maya',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            state.error?.replaceFirst('ConversationException: ', '') ??
                'Please check your internet connection.',
            style: AppTypography.body.copyWith(
              color: Colors.white.withOpacity(0.55),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xl),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.brandPurple],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(assessmentProvider.notifier).reset();
                  Future.microtask(
                      () => ref.read(assessmentProvider.notifier).startAssessment());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: const Text('Try Again', style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AssessmentState state, bool isListening) {
    if (_voiceState == VoiceState.speaking) return 'Maya is speaking...';
    if (isListening) return 'Listening... tap to stop';
    if (_voiceState == VoiceState.processing) return 'Processing...';
    if (state.status == AssessmentStatus.active) return 'Tap to speak';
    return '';
  }
}

// ─── Progress Dots (dark) ─────────────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < current
              ? AppColors.lightPurple
              : Colors.white.withOpacity(0.2),
        ),
      )),
    );
  }
}

// ─── Dark Speech Bubble — matches Voice Session ───────────────────────────────
class _DarkSpeechBubble extends StatelessWidget {
  const _DarkSpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
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
}

// ─── Dark Thinking Bubble — matches Voice Session ─────────────────────────────
class _DarkThinkingBubble extends StatefulWidget {
  @override
  State<_DarkThinkingBubble> createState() => _DarkThinkingBubbleState();
}

class _DarkThinkingBubbleState extends State<_DarkThinkingBubble>
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Maya is thinking',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(3, (i) {
              final opacity = ((_controller.value * 3) - i).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity * 0.5),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Dark Live Transcript — matches Voice Session ─────────────────────────────
class _DarkTranscriptBubble extends StatelessWidget {
  const _DarkTranscriptBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md, vertical: AppDimensions.mdMinus,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: const Border(
          left: BorderSide(color: AppColors.blue, width: 4),
        ),
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Dark Mic Button — matches Voice Session ──────────────────────────────────
class _DarkMicButton extends StatelessWidget {
  const _DarkMicButton({
    required this.isListening,
    required this.isDisabled,
    required this.onTap,
  });

  final bool isListening;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

// ─── Dark Fallback Text Input ─────────────────────────────────────────────────
class _DarkFallbackInput extends StatelessWidget {
  const _DarkFallbackInput({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: AppTypography.bodyLarge.copyWith(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                hintStyle: AppTypography.body.copyWith(
                  color: Colors.white.withOpacity(0.35),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10,
                ),
              ),
              onSubmitted: enabled ? (_) => onSubmit() : null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? onSubmit : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? AppColors.blue : AppColors.bg600,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: enabled ? Colors.white : AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
