import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/score_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/score.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scoreHistoryProvider);
    final streakAsync = ref.watch(streakProvider);
    final avgAsync = ref.watch(averageScoresProvider);
    final profile = ref.watch(userProfileNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPage,
            elevation: 0,
            title: const Text('Your Progress', style: AppTypography.h2),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatsRow(
                  totalSessions: profile?.totalSessions ?? 0,
                  totalMinutes: profile?.totalMinutes ?? 0,
                  currentStreak: streakAsync.value?.currentStreak ?? 0,
                ),
                const SizedBox(height: AppDimensions.lg),
                avgAsync.when(
                  data: (scores) => _AverageScoresCard(scores: scores),
                  loading: () => const _SkeletonBox(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.lg),
                historyAsync.when(
                  data: (history) => history.isEmpty
                      ? const _EmptyProgressCard()
                      : _ScoreChart(history: history),
                  loading: () => const _SkeletonBox(height: 220),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.lg),
                historyAsync.when(
                  data: (history) => history.isEmpty
                      ? const SizedBox.shrink()
                      : _RecentScoresList(history: history.take(10).toList()),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.xl3),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
  });

  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(value: '$totalSessions', label: 'Sessions'),
        const SizedBox(width: AppDimensions.sm),
        _StatCard(value: '$totalMinutes', label: 'Minutes'),
        const SizedBox(width: AppDimensions.sm),
        _StatCard(value: '🔥$currentStreak', label: 'Streak'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
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
            Text(value, style: AppTypography.h1.copyWith(
              fontFamily: 'DMMonoMedium',
            )),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

class _AverageScoresCard extends StatelessWidget {
  const _AverageScoresCard({required this.scores});

  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    final isZero = scores.values.every((v) => v == 0);
    if (isZero) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Center(
          child: Text('Complete sessions to see your scores',
              style: AppTypography.body),
        ),
      );
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Average Scores', style: AppTypography.h3),
          const SizedBox(height: AppDimensions.md),
          _ScoreBar(label: 'Confidence', value: scores['confidence'] ?? 0),
          const SizedBox(height: AppDimensions.sm),
          _ScoreBar(label: 'Fluency', value: scores['fluency'] ?? 0),
          const SizedBox(height: AppDimensions.sm),
          _ScoreBar(label: 'Communication', value: scores['communication'] ?? 0),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.body),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.bgSurface2,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        SizedBox(
          width: 36,
          child: Text(
            '${value.toInt()}',
            style: AppTypography.caption.copyWith(
              color: color,
              fontFamily: 'DMMonoMedium',
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _ScoreChart extends StatelessWidget {
  const _ScoreChart({required this.history});

  final List<ScoreHistory> history;

  @override
  Widget build(BuildContext context) {
    final reversed = history.reversed.toList();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overall Score Trend', style: AppTypography.h3),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.borderSubtle,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: AppTypography.micro,
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: reversed.asMap().entries.map((e) => FlSpot(
                      e.key.toDouble(),
                      e.value.overallScore,
                    )).toList(),
                    isCurved: true,
                    color: AppColors.blue,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.blue.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentScoresList extends StatelessWidget {
  const _RecentScoresList({required this.history});

  final List<ScoreHistory> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Session History', style: AppTypography.h3),
        const SizedBox(height: AppDimensions.md),
        ...history.map((s) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(s.recordedAt),
                  style: AppTypography.body,
                ),
              ),
              _ScorePill(label: 'C', value: s.confidenceScore),
              const SizedBox(width: 4),
              _ScorePill(label: 'F', value: s.fluencyScore),
              const SizedBox(width: 4),
              _ScorePill(label: 'M', value: s.communicationScore),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label:${value.toInt()}',
        style: AppTypography.micro.copyWith(
          color: color,
          fontFamily: 'DMMonoMedium',
        ),
      ),
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  const _EmptyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_rounded,
              color: AppColors.textTertiary, size: 48),
          const SizedBox(height: AppDimensions.md),
          Text('No data yet', style: AppTypography.h3.copyWith(
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: AppDimensions.sm),
          const Text(
            'Complete your first session to see\nyour progress charts',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        color: AppColors.bgSurface2,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
    );
  }
}
