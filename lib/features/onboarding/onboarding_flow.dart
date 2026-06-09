import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/boloo_button.dart';
import '../../shared/widgets/maya_avatar.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  String _language = 'mixed';
  String _goal = 'jobInterview';
  String _level = 'intermediate';
  bool _saving = false;

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      await ref.read(userProfileNotifierProvider.notifier).completeOnboarding(
        languagePreference: _language,
        primaryGoal: _goal,
        englishLevel: _level,
        occupation: null,
        dailyCommitmentMin: 15,
      );
      if (mounted) context.go('/maya-welcome');
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.xl),
                    _buildMayaIntro(),
                    const SizedBox(height: AppDimensions.xl2),
                    // Language preference
                    Text(
                      'আপনি কোন ভাষায় কথা বলতে চান?',
                      style: AppTypography.h1,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Which language do you prefer with Maya?',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildLanguageOptions(),
                    const SizedBox(height: AppDimensions.xl2),
                    // Primary goal
                    Text("What's your main goal?", style: AppTypography.h1),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Choose the outcome you want most.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildGoalOptions(),
                    const SizedBox(height: AppDimensions.xl2),
                    // English level
                    Text("What's your current level?", style: AppTypography.h1),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Be honest — Maya tailors sessions to your level.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildLevelOptions(),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.md,
              ),
              child: BoolooButton.primary(
                label: _saving ? 'Starting...' : 'Meet Maya →',
                onPressed: _saving ? null : _complete,
                isLoading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMayaIntro() {
    return Row(
      children: [
        const MayaAvatar(state: MayaState.idle, size: 52),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Text(
              "Hi! I'm Maya — your personal AI English coach. A few quick questions to personalise your journey:",
              style: AppTypography.body,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions() {
    return Column(
      children: [
        _SelectionCard(
          emoji: '🌟',
          label: 'Mixed Mode',
          subtitle: 'বাংলা + English — Best for most learners',
          selected: _language == 'mixed',
          onTap: () => setState(() => _language = 'mixed'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '🇺🇸',
          label: 'English Only',
          subtitle: 'Full English immersion',
          selected: _language == 'english',
          onTap: () => setState(() => _language = 'english'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '🇧🇩',
          label: 'বাংলা',
          subtitle: 'Full Bangla — Maya explains in Bangla',
          selected: _language == 'bangla',
          onTap: () => setState(() => _language = 'bangla'),
        ),
      ],
    );
  }

  Widget _buildGoalOptions() {
    return Column(
      children: [
        _SelectionCard(
          emoji: '🎯',
          label: 'Job Interview',
          subtitle: 'Ace interviews and get hired faster',
          selected: _goal == 'jobInterview',
          onTap: () => setState(() => _goal = 'jobInterview'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '💼',
          label: 'Freelancing',
          subtitle: 'Win international clients with confidence',
          selected: _goal == 'freelancing',
          onTap: () => setState(() => _goal = 'freelancing'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '🏢',
          label: 'Corporate Growth',
          subtitle: 'Lead meetings and presentations',
          selected: _goal == 'corporate',
          onTap: () => setState(() => _goal = 'corporate'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '📚',
          label: 'IELTS / Exam',
          subtitle: 'Score higher in English exams',
          selected: _goal == 'ielts',
          onTap: () => setState(() => _goal = 'ielts'),
        ),
      ],
    );
  }

  Widget _buildLevelOptions() {
    return Column(
      children: [
        _SelectionCard(
          emoji: '🌱',
          label: 'Beginner',
          subtitle: 'I struggle with basic English sentences',
          selected: _level == 'beginner',
          onTap: () => setState(() => _level = 'beginner'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '⚡',
          label: 'Intermediate',
          subtitle: 'I can communicate but lack confidence',
          selected: _level == 'intermediate',
          onTap: () => setState(() => _level = 'intermediate'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _SelectionCard(
          emoji: '🚀',
          label: 'Upper Intermediate',
          subtitle: 'I speak well but want to be excellent',
          selected: _level == 'upperIntermediate',
          onTap: () => setState(() => _level = 'upperIntermediate'),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueLight : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.h3),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
