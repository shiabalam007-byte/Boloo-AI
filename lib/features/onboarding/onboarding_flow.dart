import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/boloo_button.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  String _language = 'mixed';
  bool _saving = false;

  Future<void> _complete() async {
    setState(() => _saving = true);
    await ref.read(userProfileNotifierProvider.notifier).completeOnboarding(
      languagePreference: _language,
      primaryGoal: 'jobInterview',
      englishLevel: 'intermediate',
      occupation: null,
      dailyCommitmentMin: 15,
    );
    if (mounted) context.go('/assessment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.xl),
              _buildMayaIntro(),
              const SizedBox(height: AppDimensions.xl2),
              Text(
                'আপনি কোন ভাষায় কথা বলতে চান?',
                style: AppTypography.h1,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Which language do you prefer with Maya?',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xl),
              _buildLanguageOptions(),
              const Spacer(),
              BoolooButton.primary(
                label: _saving ? 'Starting...' : 'Meet Maya →',
                onPressed: _saving ? null : _complete,
                isLoading: _saving,
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMayaIntro() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blue, AppColors.brandPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('M', style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
          ),
        ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Hi! I\'m Maya — your personal AI English coach. Before we start, quick question:',
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
        _LanguageCard(
          emoji: '🌟',
          label: 'Mixed Mode',
          subtitle: 'বাংলা + English — Best for most learners',
          selected: _language == 'mixed',
          onTap: () => setState(() => _language = 'mixed'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _LanguageCard(
          emoji: '🇺🇸',
          label: 'English Only',
          subtitle: 'Full English immersion',
          selected: _language == 'english',
          onTap: () => setState(() => _language = 'english'),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        _LanguageCard(
          emoji: '🇧🇩',
          label: 'বাংলা',
          subtitle: 'Full Bangla — Maya explains in Bangla',
          selected: _language == 'bangla',
          onTap: () => setState(() => _language = 'bangla'),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
