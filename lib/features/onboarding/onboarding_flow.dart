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
  int _step = 0;
  final _pageController = PageController();

  String _language = 'mixed';
  String _goal = 'jobInterview';
  String _level = 'intermediate';
  String _occupation = '';
  int _dailyMin = 15;

  final _occupationController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _complete() async {
    await ref.read(userProfileNotifierProvider.notifier).completeOnboarding(
      languagePreference: _language,
      primaryGoal: _goal,
      englishLevel: _level,
      occupation: _occupation.isEmpty ? null : _occupation,
      dailyCommitmentMin: _dailyMin,
    );
    if (mounted) context.go('/meet-maya');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LanguageStep(
                    selected: _language,
                    onSelect: (v) => setState(() => _language = v),
                    onNext: _next,
                  ),
                  _GoalStep(
                    selected: _goal,
                    onSelect: (v) => setState(() => _goal = v),
                    onNext: _next,
                    onBack: _back,
                  ),
                  _LevelStep(
                    selected: _level,
                    onSelect: (v) => setState(() => _level = v),
                    onNext: _next,
                    onBack: _back,
                  ),
                  _OccupationStep(
                    controller: _occupationController,
                    onChanged: (v) => _occupation = v,
                    onNext: _next,
                    onBack: _back,
                  ),
                  _CommitmentStep(
                    selected: _dailyMin,
                    onSelect: (v) => setState(() => _dailyMin = v),
                    onNext: _next,
                    onBack: _back,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0,
      ),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _step ? AppColors.brandPurple : AppColors.bg500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'আপনি কোন ভাষায় কথা বলতে চান?',
      subtitle: 'Which language do you prefer?',
      onNext: onNext,
      child: Column(
        children: [
          _SelectCard(
            label: 'বাংলা',
            subtitle: 'Full Bangla session',
            emoji: '🇧🇩',
            selected: selected == 'bangla',
            onTap: () => onSelect('bangla'),
          ),
          const SizedBox(height: AppDimensions.mdMinus),
          _SelectCard(
            label: 'English',
            subtitle: 'Full English session',
            emoji: '🇺🇸',
            selected: selected == 'english',
            onTap: () => onSelect('english'),
          ),
          const SizedBox(height: AppDimensions.mdMinus),
          _SelectCard(
            label: 'Mixed Mode',
            subtitle: 'বাংলা + English (Recommended)',
            emoji: '🌟',
            selected: selected == 'mixed',
            onTap: () => onSelect('mixed'),
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const goals = [
      ('jobInterview', '💼', 'Job Interview', 'চাকরির ইন্টারভিউ'),
      ('freelancing', '💻', 'Freelancing', 'Upwork / Fiverr'),
      ('corporate', '🏢', 'Corporate', 'Workplace communication'),
      ('ielts', '📚', 'IELTS Speaking', 'Band score improvement'),
      ('abroad', '✈️', 'Study Abroad', 'বিদেশে পড়াশোনা'),
    ];

    return _OnboardingPage(
      title: 'আপনার মূল লক্ষ্য কী?',
      subtitle: 'What is your primary goal?',
      onNext: onNext,
      onBack: onBack,
      child: Column(
        children: goals.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.mdMinus),
          child: _SelectCard(
            label: g.$3,
            subtitle: g.$4,
            emoji: g.$2,
            selected: selected == g.$1,
            onTap: () => onSelect(g.$1),
          ),
        )).toList(),
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  const _LevelStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'আপনার ইংরেজি এখন কেমন?',
      subtitle: 'What is your current English level?',
      onNext: onNext,
      onBack: onBack,
      child: Column(
        children: [
          _SelectCard(
            label: 'Beginner',
            subtitle: 'I can understand basic English',
            emoji: '🌱',
            selected: selected == 'beginner',
            onTap: () => onSelect('beginner'),
          ),
          const SizedBox(height: AppDimensions.mdMinus),
          _SelectCard(
            label: 'Intermediate',
            subtitle: 'I understand well, hard to speak',
            emoji: '🌿',
            selected: selected == 'intermediate',
            onTap: () => onSelect('intermediate'),
          ),
          const SizedBox(height: AppDimensions.mdMinus),
          _SelectCard(
            label: 'Upper Intermediate',
            subtitle: 'I speak some but need confidence',
            emoji: '🌳',
            selected: selected == 'upperIntermediate',
            onTap: () => onSelect('upperIntermediate'),
          ),
        ],
      ),
    );
  }
}

class _OccupationStep extends StatelessWidget {
  const _OccupationStep({
    required this.controller,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Software Developer', 'Student', 'Freelancer',
      'Marketing Professional', 'Business Owner', 'Teacher',
      'Engineer', 'BBA / MBA Student',
    ];

    return _OnboardingPage(
      title: 'আপনি কী করেন?',
      subtitle: 'What is your occupation?',
      onNext: onNext,
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'e.g., Software Developer, Student...',
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) => GestureDetector(
              onTap: () {
                controller.text = s;
                onChanged(s);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bg600,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.bg500),
                ),
                child: Text(s, style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                )),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _CommitmentStep extends StatelessWidget {
  const _CommitmentStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'প্রতিদিন কতটুকু সময়?',
      subtitle: 'How much time can you practice daily?',
      onNext: onNext,
      onBack: onBack,
      nextLabel: "Let's Begin!",
      child: Column(
        children: [10, 15, 20, 30].map((min) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.mdMinus),
          child: _SelectCard(
            label: '$min minutes',
            subtitle: min == 10 ? 'Quick daily habit' :
                      min == 15 ? 'Recommended for steady growth' :
                      min == 20 ? 'Faster improvement' :
                      'Maximum results',
            emoji: min == 10 ? '⚡' : min == 15 ? '⭐' : min == 20 ? '🔥' : '🚀',
            selected: selected == min,
            onTap: () => onSelect(min),
          ),
        )).toList(),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    this.onBack,
    this.nextLabel = 'Continue',
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.lg),
          Text(title, style: AppTypography.h1),
          const SizedBox(height: AppDimensions.xs),
          Text(subtitle, style: AppTypography.body),
          const SizedBox(height: AppDimensions.xl),
          Expanded(child: SingleChildScrollView(child: child)),
          const SizedBox(height: AppDimensions.md),
          BoolooButton.primary(label: nextLabel, onPressed: onNext),
          if (onBack != null) ...[
            const SizedBox(height: AppDimensions.mdMinus),
            BoolooButton.ghost(label: 'Back', onPressed: onBack!),
          ],
        ],
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final String emoji;
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
          color: selected ? AppColors.brandPurple.withOpacity(0.15) : AppColors.bg700,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? AppColors.brandPurple : AppColors.bg500,
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
              const Icon(Icons.check_circle_rounded, color: AppColors.brandPurple),
          ],
        ),
      ),
    );
  }
}
