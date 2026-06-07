import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/boloo_button.dart';

class MeetMayaScreen extends ConsumerStatefulWidget {
  const MeetMayaScreen({super.key});

  @override
  ConsumerState<MeetMayaScreen> createState() => _MeetMayaScreenState();
}

class _MeetMayaScreenState extends ConsumerState<MeetMayaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _messageIndex = 0;

  final _messages = [
    'Hi! I am Maya. 👋',
    'I am your personal AI English coach.',
    'Together, we will build your confidence.',
    'Your 30-day transformation starts now!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _cycleMessages();
  }

  void _cycleMessages() async {
    for (int i = 1; i < _messages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      _controller.reset();
      setState(() => _messageIndex = i);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    final name = profile.value?.fullName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              const Spacer(),
              _buildMayaAvatar(),
              const SizedBox(height: AppDimensions.xl),
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  _messages[_messageIndex],
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'আমরা একসাথে আপনার ইংরেজি ভাষায়\nকথা বলার দক্ষতা উন্নত করব।',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              BoolooButton.primary(
                label: 'Start My Journey →',
                onPressed: () => context.go('/paywall'),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMayaAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandPurple, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPurple.withOpacity(0.4),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text('M', style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        )),
      ),
    );
  }
}
