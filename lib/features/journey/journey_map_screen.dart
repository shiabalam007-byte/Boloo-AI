import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/journey_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/curriculum_day.dart';

class JourneyMapScreen extends ConsumerWidget {
  const JourneyMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(curriculumDaysProvider);
    final progressAsync = ref.watch(userJourneyProgressProvider);
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final currentDay = profileAsync.value?.currentDay ?? 1;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPage,
            title: const Text('Your Journey', style: AppTypography.h2),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (currentDay / 90).clamp(0.0, 1.0),
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: const AlwaysStoppedAnimation(AppColors.brandPurple),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Text(
                      'Day $currentDay / 90',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.lightPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          daysAsync.when(
            data: (days) => progressAsync.when(
              data: (progress) => _buildJourneyList(
                context, days, progress, currentDay,
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brandPurple),
                ),
              ),
              error: (e, _) => SliverFillRemaining(child: Center(child: Text('$e'))),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandPurple),
              ),
            ),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('$e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyList(
    BuildContext context,
    List<CurriculumDay> days,
    Map<int, DayStatus> progress,
    int currentDay,
  ) {
    final grouped = <String, List<CurriculumDay>>{};
    for (final day in days) {
      grouped.putIfAbsent(day.phase, () => []).add(day);
    }

    final sections = grouped.entries.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == sections.length) {
            return const SizedBox(height: AppDimensions.xl3);
          }
          final section = sections[index];
          final phase = section.key;
          final phaseDays = section.value;
          return _PhaseSection(
            phase: phase,
            days: phaseDays,
            progress: progress,
            currentDay: currentDay,
            onTap: (day) {
              final status = progress[day.dayNumber] ?? DayStatus.locked;
              if (status != DayStatus.locked) {
                context.push('/session/voice', extra: <String, dynamic>{
                  'topic': day.titleEn,
                  'scenario': day.scenarioPrompt,
                  'journeyDay': day.dayNumber,
                });
              }
            },
          );
        },
        childCount: sections.length + 1,
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.phase,
    required this.days,
    required this.progress,
    required this.currentDay,
    required this.onTap,
  });

  final String phase;
  final List<CurriculumDay> days;
  final Map<int, DayStatus> progress;
  final int currentDay;
  final ValueChanged<CurriculumDay> onTap;

  String get _phaseLabel {
    switch (phase) {
      case 'foundation': return '🌱 Foundation';
      case 'professional': return '💼 Professional';
      case 'interview': return '🎯 Interview Mastery';
      case 'workplace': return '🏢 Workplace';
      case 'confidence': return '🔥 Confidence';
      default: return phase;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(_phaseLabel, style: AppTypography.caption.copyWith(
              color: AppColors.lightPurple,
              fontWeight: FontWeight.w600,
            )),
          ),
          const SizedBox(height: AppDimensions.md),
          ...days.map((day) {
            final status = progress[day.dayNumber] ?? DayStatus.locked;
            final isCurrent = day.dayNumber == currentDay;
            return _DayCard(
              day: day,
              status: status,
              isCurrent: isCurrent,
              onTap: () => onTap(day),
            );
          }),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.status,
    required this.isCurrent,
    required this.onTap,
  });

  final CurriculumDay day;
  final DayStatus status;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == DayStatus.locked;
    final isCompleted = status == DayStatus.completed;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.brandPurple.withOpacity(0.15)
              : isLocked
                  ? AppColors.bgPage
                  : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isCurrent
                ? AppColors.brandPurple
                : AppColors.borderSubtle,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildDayBadge(isLocked, isCompleted, isCurrent),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.isMilestone)
                    Text('★ MILESTONE', style: AppTypography.micro.copyWith(
                      color: AppColors.warning,
                    )),
                  Text(
                    day.titleEn,
                    style: AppTypography.h3.copyWith(
                      color: isLocked
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${day.estimatedMin} min • ${day.phase}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline_rounded,
                  color: AppColors.textTertiary, size: 18)
            else if (isCompleted)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 20)
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBadge(bool isLocked, bool isCompleted, bool isCurrent) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withOpacity(0.15)
            : isCurrent
                ? AppColors.brandPurple
                : AppColors.bgSurface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${day.dayNumber}',
          style: TextStyle(
            fontFamily: 'DMMonoMedium',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? Colors.white
                    : isLocked
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
