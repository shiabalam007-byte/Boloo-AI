import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../models/conversation.dart';
import '../../shared/widgets/boloo_button.dart';

class ScorecardScreen extends ConsumerStatefulWidget {
  const ScorecardScreen({
    super.key,
    required this.scores,
    required this.conversation,
  });

  final Map<String, dynamic>? scores;
  final Conversation? conversation;

  @override
  ConsumerState<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends ConsumerState<ScorecardScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late List<Animation<double>> _scoreAnims;
  final List<double> _displayScores = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scoreAnims = List.generate(
      3,
      (i) => Tween<double>(
        begin: 0,
        end: _getScore(i),
      ).animate(CurvedAnimation(
        parent: _revealController,
        curve: Interval(i * 0.15, 0.5 + i * 0.15, curve: Curves.easeOutCubic),
      )),
    );

    _revealController.addListener(() {
      setState(() {
        for (int i = 0; i < 3; i++) {
          _displayScores[i] = _scoreAnims[i].value;
        }
      });
    });

    _revealController.forward();
  }

  double _getScore(int index) {
    final s = widget.scores;
    if (s == null) return 60;
    switch (index) {
      case 0:
        return (s['confidence_score'] as num?)?.toDouble() ?? 60;
      case 1:
        return (s['fluency_score'] as num?)?.toDouble() ?? 60;
      case 2:
        return (s['communication_score'] as num?)?.toDouble() ?? 60;
      default:
        return 60;
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = widget.scores?['maya_feedback'] as String? ??
        'Great session! Keep practicing every day for the best results.';
    final strengths = List<String>.from(
        widget.scores?['strengths'] as List? ?? ['Good effort!']);
    final improvements = List<String>.from(
        widget.scores?['improvements'] as List? ?? ['Keep practicing']);

    return Scaffold(
      backgroundColor: AppColors.bg900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.md),
              _buildHeader(),
              const SizedBox(height: AppDimensions.xl),
              _buildScoresRow(),
              const SizedBox(height: AppDimensions.xl),
              _buildMayaFeedback(feedback),
              const SizedBox(height: AppDimensions.lg),
              if (strengths.isNotEmpty) _buildStrengthsCard(strengths),
              const SizedBox(height: AppDimensions.md),
              if (improvements.isNotEmpty) _buildImprovementsCard(improvements),
              const SizedBox(height: AppDimensions.xl),
              BoolooButton.primary(
                label: 'Continue Journey →',
                onPressed: () => context.go('/dashboard'),
              ),
              const SizedBox(height: AppDimensions.mdMinus),
              BoolooButton.ghost(
                label: 'Practice Again',
                onPressed: () => context.go('/session/setup'),
              ),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final overall = widget.scores?['overall_score'] as num? ?? 60;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
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
              '${overall.toInt()}',
              style: AppTypography.displayXL.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        const Text('Session Complete!', style: AppTypography.h1),
        const SizedBox(height: AppDimensions.xs),
        Text(
          widget.conversation?.topic ?? 'Practice Session',
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildScoresRow() {
    const labels = ['Confidence', 'Fluency', 'Communication'];

    return Row(
      children: List.generate(3, (i) {
        final score = _displayScores[i];
        final color = AppColors.scoreColor(score);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 4,
              right: i == 2 ? 0 : 4,
            ),
            child: _AnimatedScoreCard(
              label: labels[i],
              score: score,
              color: color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMayaFeedback(String feedback) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandPurple.withOpacity(0.15),
            AppColors.teal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.brandPurple.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandPurple, AppColors.teal],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
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
                  "Maya's Feedback",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(feedback, style: AppTypography.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard(List<String> strengths) {
    return _FeedbackSection(
      title: 'What you did well',
      items: strengths,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  Widget _buildImprovementsCard(List<String> improvements) {
    return _FeedbackSection(
      title: 'Focus on next',
      items: improvements,
      color: AppColors.lightPurple,
      icon: Icons.lightbulb_outline_rounded,
    );
  }
}

class _AnimatedScoreCard extends StatelessWidget {
  const _AnimatedScoreCard({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${score.toInt()}',
            style: AppTypography.scoreNumber.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.micro, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.bg500,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppDimensions.sm),
              Text(title, style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7, right: 8),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(item, style: AppTypography.body),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
