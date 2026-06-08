import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/score_provider.dart';
import '../../providers/journey_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../models/conversation.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final streakAsync = ref.watch(streakProvider);
    final avgScoresAsync = ref.watch(averageScoresProvider);
    final todayChallengeAsync = ref.watch(todaysChallengeProvider);
    final recentAsync = ref.watch(recentSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(ref, profileAsync.value?.currentDay ?? 1,
              streakAsync.value?.currentStreak ?? 0),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MayaGreetingCard(
                  name: profileAsync.value?.fullName?.split(' ').first ?? 'there',
                  day: profileAsync.value?.currentDay ?? 1,
                  onTap: () => context.push('/session/setup'),
                ),
                const SizedBox(height: AppDimensions.md),
                todayChallengeAsync.when(
                  data: (day) => day != null
                      ? _TodayChallengeCard(
                          day: day,
                          onTap: () => context.push('/session/setup'),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const _CardSkeleton(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.md),
                avgScoresAsync.when(
                  data: (scores) => _ScoreRow(scores: scores),
                  loading: () => const _CardSkeleton(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.md),
                const _SectionHeader(title: 'Recent Sessions'),
                const SizedBox(height: AppDimensions.sm),
                recentAsync.when(
                  data: (sessions) => sessions.isEmpty
                      ? _EmptySessionsCard(onTap: () => context.push('/session/setup'))
                      : Column(
                          children: sessions.take(3).map((s) => _SessionCard(
                            conversation: s,
                          )).toList(),
                        ),
                  loading: () => const _CardSkeleton(height: 80),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.xl3),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session/setup'),
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: const Text('Practice Now', style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  SliverAppBar _buildAppBar(WidgetRef ref, int day, int streak) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.bgPage,
      title: Row(
        children: [
          Text(
            'BOLOO',
            style: AppTypography.h2.copyWith(color: AppColors.blue),
          ),
          Text(' AI', style: AppTypography.h2),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Day $day',
              style: AppTypography.caption.copyWith(color: AppColors.blue),
            ),
          ),
          const SizedBox(width: 8),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$streak', style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MayaGreetingCard extends StatelessWidget {
  const _MayaGreetingCard({
    required this.name,
    required this.day,
    required this.onTap,
  });

  final String name;
  final int day;
  final VoidCallback onTap;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.blue, AppColors.brandPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusHero),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting, $name!',
                    style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Ready for Day $day? Let\'s practice!',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _TodayChallengeCard extends StatelessWidget {
  const _TodayChallengeCard({required this.day, required this.onTap});

  final dynamic day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.today_rounded, color: AppColors.teal, size: 24),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Challenge',
                      style: AppTypography.caption.copyWith(color: AppColors.teal)),
                  Text(day.titleEn ?? 'Practice Session', style: AppTypography.h3),
                  Text(
                    '${day.estimatedMin ?? 15} min • ${day.phase ?? 'foundation'}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Start', style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.scores});

  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.values.every((v) => v == 0)) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.bar_chart_rounded, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'Complete a session to see your scores',
              style: AppTypography.body.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _ScoreChip(label: 'Confidence', value: scores['confidence'] ?? 0),
        const SizedBox(width: AppDimensions.sm),
        _ScoreChip(label: 'Fluency', value: scores['fluency'] ?? 0),
        const SizedBox(width: AppDimensions.sm),
        _ScoreChip(label: 'Communication', value: scores['communication'] ?? 0),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${value.toInt()}',
              style: AppTypography.scoreNumber.copyWith(color: color),
            ),
            Text(label, style: AppTypography.micro, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.h3);
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.blue, size: 18),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversation.topic ?? 'Practice Session', style: AppTypography.h3),
                Text(
                  '${_formatDate(conversation.startedAt)} • ${conversation.mode.name}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (conversation.overallScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.scoreColor(conversation.overallScore!).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${conversation.overallScore!.toInt()}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.scoreColor(conversation.overallScore!),
                  fontFamily: 'DMMonoMedium',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}';
  }
}

class _EmptySessionsCard extends StatelessWidget {
  const _EmptySessionsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.blue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.mic_none_rounded,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: AppDimensions.md),
            Text('No sessions yet', style: AppTypography.h3.copyWith(
              color: AppColors.textSecondary,
            )),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Start your first session with Maya',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSurface2,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
    );
  }
}
