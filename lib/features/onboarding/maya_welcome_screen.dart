import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../services/voice_service.dart';
import '../../shared/widgets/maya_avatar.dart';

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
      backgroundColor: AppColors.bg900,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D14), Color(0xFF0F0A1E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              MayaAvatar(state: _avatarState, size: 160),
              const SizedBox(height: AppDimensions.lg),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      _messages[_messageIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (name.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Hello, $name',
                        style: const TextStyle(
                          color: AppColors.lightPurple,
                          fontSize: 15,
                          fontFamily: 'PlusJakartaSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(flex: 3),
              AnimatedOpacity(
                opacity: _introComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: _introComplete ? () => context.go('/assessment') : null,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.blue, AppColors.brandPurple],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Let's Begin →",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              AnimatedOpacity(
                opacity: _introComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: TextButton(
                  onPressed: _introComplete
                      ? () => context.go('/assessment')
                      : null,
                  child: const Text(
                    'Skip intro',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
