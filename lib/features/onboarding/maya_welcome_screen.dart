import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../services/voice_service.dart';
import '../../shared/widgets/maya_avatar.dart';
import '../../shared/widgets/boloo_button.dart';

class MayaWelcomeScreen extends ConsumerStatefulWidget {
  const MayaWelcomeScreen({super.key});

  @override
  ConsumerState<MayaWelcomeScreen> createState() => _MayaWelcomeScreenState();
}

class _MayaWelcomeScreenState extends ConsumerState<MayaWelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _voiceService = VoiceService();
  MayaState _avatarState = MayaState.idle;
  int _messageIndex = 0;
  bool _introComplete = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const _messages = [
    "Hi! I'm Maya, your AI English coach.",
    "I'll help you speak with confidence.",
    "First, I'd like to understand your goals.",
    "Let's start with a short 4-question conversation.",
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _voiceService.initialize().then((_) => _runIntro());
  }

  Future<void> _runIntro() async {
    setState(() => _avatarState = MayaState.speaking);
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) return;
      setState(() => _messageIndex = i);
      _fadeController.reset();
      _fadeController.forward();
      await _voiceService.speak(_messages[i]);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
    }
    if (mounted) {
      setState(() {
        _avatarState = MayaState.idle;
        _introComplete = true;
      });
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    final name = profile.value?.fullName?.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              const Spacer(),
              MayaAvatar(state: _avatarState, size: 110),
              const SizedBox(height: AppDimensions.xl),
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  _messages[_messageIndex],
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              if (name.isNotEmpty)
                Text(
                  name,
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _introComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: BoolooButton.primary(
                  label: "Let's Begin →",
                  onPressed: _introComplete
                      ? () => context.go('/assessment')
                      : null,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              AnimatedOpacity(
                opacity: _introComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: TextButton(
                  onPressed: _introComplete
                      ? () => context.go('/assessment')
                      : null,
                  child: Text(
                    'Skip intro',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}
