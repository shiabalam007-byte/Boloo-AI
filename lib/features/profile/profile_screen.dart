import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../shared/widgets/boloo_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bg900,
            title: Text('Profile', style: AppTypography.h2),
            actions: [
              _SettingsButton(),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                profileAsync.when(
                  data: (profile) => profile != null
                      ? _ProfileHeader(profile: profile)
                      : const _ProfileHeaderSkeleton(),
                  loading: () => const _ProfileHeaderSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.xl),
                streakAsync.when(
                  data: (streak) => streak != null
                      ? _StreakCard(streak: streak)
                      : const SizedBox.shrink(),
                  loading: () => const _SkeletonBox(height: 80),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.lg),
                profileAsync.when(
                  data: (profile) => profile != null
                      ? _StatsCard(profile: profile)
                      : const SizedBox.shrink(),
                  loading: () => const _SkeletonBox(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.lg),
                profileAsync.when(
                  data: (profile) => profile != null
                      ? _LearningPreferences(profile: profile)
                      : const SizedBox.shrink(),
                  loading: () => const _SkeletonBox(height: 200),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.xl),
                BoolooButton.secondary(
                  label: 'Sign Out',
                  prefixIcon: Icons.logout_rounded,
                  onPressed: () => _signOut(context, ref),
                ),
                const SizedBox(height: AppDimensions.xl3),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) context.go('/auth');
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => context.push('/settings'),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.fullName != null
        ? profile.fullName!
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : 'U';

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandPurple, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName ?? 'BOLOO Learner',
                style: AppTypography.h2,
              ),
              if (profile.occupation != null)
                Text(profile.occupation!, style: AppTypography.body),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Day ${profile.currentDay} of 90',
                  style: AppTypography.micro.copyWith(color: AppColors.lightPurple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final dynamic streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streak.currentStreak} Day Streak!',
                  style: AppTypography.h3.copyWith(color: AppColors.warning),
                ),
                Text(
                  'Longest: ${streak.longestStreak} days • Total: ${streak.totalActiveDays} days',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bg500),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '${profile.totalSessions}',
            label: 'Sessions',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          _VerticalDivider(),
          _StatItem(
            value: '${profile.totalMinutes}',
            label: 'Minutes',
            icon: Icons.timer_outlined,
          ),
          _VerticalDivider(),
          _StatItem(
            value: 'Day ${profile.currentDay}',
            label: 'Progress',
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.bg500,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.lightPurple, size: 20),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h3),
          Text(label, style: AppTypography.micro),
        ],
      ),
    );
  }
}

class _LearningPreferences extends StatelessWidget {
  const _LearningPreferences({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final prefs = [
      ('Goal', _goalLabel(profile.primaryGoal), Icons.flag_rounded),
      ('Level', _levelLabel(profile.englishLevel), Icons.trending_up_rounded),
      ('Language', _langLabel(profile.languagePreference), Icons.language_rounded),
      ('Daily Goal', '${profile.dailyCommitmentMin} min/day', Icons.timer_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bg500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Preferences', style: AppTypography.h3),
          const SizedBox(height: AppDimensions.md),
          ...prefs.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Row(
              children: [
                Icon(p.$3, color: AppColors.textTertiary, size: 16),
                const SizedBox(width: AppDimensions.sm),
                Text(p.$1, style: AppTypography.body),
                const Spacer(),
                Text(
                  p.$2,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _goalLabel(PrimaryGoal? goal) {
    switch (goal) {
      case PrimaryGoal.jobInterview: return 'Job Interview';
      case PrimaryGoal.freelancing: return 'Freelancing';
      case PrimaryGoal.corporate: return 'Corporate';
      case PrimaryGoal.ielts: return 'IELTS';
      case PrimaryGoal.abroad: return 'Study Abroad';
      default: return 'Not set';
    }
  }

  String _levelLabel(EnglishLevel? level) {
    switch (level) {
      case EnglishLevel.beginner: return 'Beginner';
      case EnglishLevel.intermediate: return 'Intermediate';
      case EnglishLevel.upperIntermediate: return 'Upper Intermediate';
      default: return 'Not set';
    }
  }

  String _langLabel(LanguagePreference pref) {
    switch (pref) {
      case LanguagePreference.bangla: return 'বাংলা';
      case LanguagePreference.english: return 'English';
      case LanguagePreference.mixed: return 'Mixed Mode';
    }
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.bg700,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        const Expanded(child: _SkeletonBox(height: 60)),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
    );
  }
}
