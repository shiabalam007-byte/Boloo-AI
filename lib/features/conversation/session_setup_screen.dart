import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/journey_provider.dart';
import '../../models/conversation.dart';
import '../../shared/widgets/boloo_button.dart';

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  SessionMode _mode = SessionMode.voice;
  bool _isStarting = false;

  Future<void> _startSession() async {
    setState(() => _isStarting = true);
    try {
      final profile = ref.read(userProfileNotifierProvider).value;
      final today = await ref.read(journeyServiceProvider).getDay(
        profile?.currentDay ?? 1,
      );

      await ref.read(activeConversationProvider.notifier).startSession(
        mode: _mode,
        sessionType: SessionType.dailyChallenge,
        journeyDay: profile?.currentDay ?? 1,
        topic: today?.titleEn,
        scenario: today?.scenarioPrompt,
      );

      final convo = ref.read(activeConversationProvider).conversation;
      if (convo == null || !mounted) return;

      if (_mode == SessionMode.voice) {
        context.push('/session/voice/${convo.id}');
      } else {
        context.push('/session/text/${convo.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start session: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todaysChallengeProvider);
    final profile = ref.watch(userProfileNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Start Session', style: AppTypography.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            todayAsync.when(
              data: (day) => day != null
                  ? _TopicCard(day: day, currentDay: profile?.currentDay ?? 1)
                  : const SizedBox.shrink(),
              loading: () => const _SkeletonBox(height: 100),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Choose your practice mode', style: AppTypography.h3),
            const SizedBox(height: AppDimensions.md),
            _ModeSelector(
              selected: _mode,
              onSelect: (m) => setState(() => _mode = m),
            ),
            const Spacer(),
            BoolooButton.primary(
              label: _mode == SessionMode.voice
                  ? '🎤  Start Voice Session'
                  : '💬  Start Text Session',
              onPressed: _isStarting ? null : _startSession,
              isLoading: _isStarting,
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.day, required this.currentDay});

  final dynamic day;
  final int currentDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withOpacity(0.15),
            AppColors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$currentDay',
                style: const TextStyle(
                  fontFamily: 'DMMonoMedium',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
                  'Day $currentDay Challenge',
                  style: AppTypography.caption.copyWith(color: AppColors.lightPurple),
                ),
                Text(day.titleEn ?? "Today's Practice", style: AppTypography.h3),
                const SizedBox(height: 4),
                Text(day.descriptionEn ?? '', style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onSelect});

  final SessionMode selected;
  final ValueChanged<SessionMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            icon: Icons.mic_rounded,
            label: 'Voice',
            subtitle: 'Speak with Maya',
            recommended: true,
            selected: selected == SessionMode.voice,
            onTap: () => onSelect(SessionMode.voice),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _ModeCard(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Text',
            subtitle: 'Type with Maya',
            recommended: false,
            selected: selected == SessionMode.text,
            onTap: () => onSelect(SessionMode.text),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.recommended,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool recommended;
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
          color: selected
              ? AppColors.blue.withOpacity(0.15)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.blue : AppColors.textSecondary,
                  size: 24,
                ),
                const Spacer(),
                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Best',
                      style: AppTypography.micro.copyWith(color: AppColors.teal),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(label, style: AppTypography.h3),
            Text(subtitle, style: AppTypography.caption),
          ],
        ),
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
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
    );
  }
}
