import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_provider.dart';

class AssessmentResultScreen extends ConsumerWidget {
  const AssessmentResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentProvider);
    final profile = ref.watch(userProfileNotifierProvider).value;
    final result = state.result ?? profile?.assessmentResult;

    if (result == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final confidenceScore = (result['confidence_score'] as num?)?.toInt() ?? 55;
    final communicationScore = (result['communication_score'] as num?)?.toInt() ?? 58;
    final strengths = (result['strengths'] as List?)?.cast<String>() ??
        ['You completed the assessment', 'You showed commitment'];
    final weaknesses = (result['weaknesses'] as List?)?.cast<String>() ??
        ['Building professional vocabulary', 'Speaking confidence'];
    final opportunity = result['biggest_opportunity'] as String? ??
        'Your career goals are within reach with the right communication skills.';
    final firstName = profile?.fullName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgPage,
            automaticallyImplyLeading: false,
            floating: true,
            elevation: 0,
            title: Row(
              children: [
                _MayaAvatar(),
                const SizedBox(width: 10),
                const Text('Maya', style: AppTypography.h3),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.xl3,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(firstName),
                const SizedBox(height: AppDimensions.xl),
                _buildScoreRow(confidenceScore, communicationScore),
                const SizedBox(height: AppDimensions.xl),
                _buildStrengths(strengths),
                const SizedBox(height: AppDimensions.lg),
                _buildLockedWeaknesses(weaknesses),
                const SizedBox(height: AppDimensions.lg),
                _buildOpportunity(opportunity),
                const SizedBox(height: AppDimensions.lg),
                _buildLockedPlan(),
                const SizedBox(height: AppDimensions.xl),
                _buildFoundingOffer(context),
                const SizedBox(height: AppDimensions.md),
                _buildSecurityNote(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✅ Assessment Complete',
            style: AppTypography.caption.copyWith(color: AppColors.success),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Your Personal\nAnalysis is Ready',
          style: AppTypography.displayL,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Based on your conversation with Maya, here is exactly where you stand — and what is possible for you.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildScoreRow(int confidence, int communication) {
    return Row(
      children: [
        Expanded(child: _ScoreCard(
          label: 'Confidence',
          score: confidence,
          icon: '💪',
        )),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _ScoreCard(
          label: 'Communication',
          score: communication,
          icon: '🗣️',
        )),
      ],
    );
  }

  Widget _buildStrengths(List<String> strengths) {
    return _ResultSection(
      title: 'Your Strengths',
      emoji: '⭐',
      titleColor: AppColors.success,
      children: strengths.take(2).map((s) => _BulletItem(text: s, color: AppColors.success)).toList(),
    );
  }

  Widget _buildLockedWeaknesses(List<String> weaknesses) {
    return Stack(
      children: [
        _ResultSection(
          title: 'Critical Weaknesses',
          emoji: '🎯',
          titleColor: AppColors.warning,
          children: weaknesses.take(2).map((w) => _BulletItem(text: w, color: AppColors.warning)).toList(),
        ),
        Positioned.fill(
          child: _BlurLock(message: 'Unlock to see your critical gaps'),
        ),
      ],
    );
  }

  Widget _buildOpportunity(String opportunity) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡 Your Biggest Opportunity',
              style: AppTypography.caption.copyWith(color: AppColors.blue)),
          const SizedBox(height: AppDimensions.xs),
          Text(opportunity, style: AppTypography.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildLockedPlan() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋 Your Personalized 90-Day Plan',
                  style: AppTypography.h3),
              const SizedBox(height: AppDimensions.md),
              ...[
                'Week 1: Breaking the fear barrier',
                'Week 2: Professional vocabulary sprint',
                'Week 3: Scenario-based confidence',
                'Week 4: Real-world simulation',
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item, style: AppTypography.body),
                  ],
                ),
              )),
            ],
          ),
        ),
        Positioned.fill(
          child: _BlurLock(message: 'Unlock your full 90-day roadmap'),
        ),
      ],
    );
  }

  Widget _buildFoundingOffer(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎁 Founding Member Offer',
              style: AppTypography.caption.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('৳', style: AppTypography.h2.copyWith(color: Colors.white.withOpacity(0.85))),
              Text('1,999', style: AppTypography.displayXL.copyWith(
                color: Colors.white,
              )),
            ],
          ),
          Text(
            'Was ৳2,999 — Limited Time',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '90 Days Full Access',
            style: AppTypography.body.copyWith(color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: AppDimensions.lg),
          _buildFeatureChips(),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/paywall'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                elevation: 0,
              ),
              child: Text(
                'Unlock My Full Program →',
                style: AppTypography.h3.copyWith(color: AppColors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChips() {
    const features = [
      '90 AI Sessions',
      '90-Day Access',
      'Progress Tracking',
      'bKash / Nagad',
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(f, style: AppTypography.micro.copyWith(color: Colors.white)),
      )).toList(),
    );
  }

  Widget _buildSecurityNote() {
    return Center(
      child: Text(
        '🔒 Secure payment via Zinnipay · bKash · Nagad · Visa · MasterCard',
        style: AppTypography.micro.copyWith(color: AppColors.textTertiary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.icon,
  });

  final String label;
  final int score;
  final String icon;

  Color get _scoreColor {
    if (score >= 70) return AppColors.success;
    if (score >= 45) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: _scoreColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '$score',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: _scoreColor,
            ),
          ),
          Text(
            '/100',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.emoji,
    required this.titleColor,
    required this.children,
  });

  final String title;
  final String emoji;
  final Color titleColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.h3.copyWith(color: titleColor)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...children,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _BlurLock extends StatelessWidget {
  const _BlurLock({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.blue, size: 22),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTypography.caption.copyWith(color: AppColors.blue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MayaAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.brandPurple],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('M', style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        )),
      ),
    );
  }
}
