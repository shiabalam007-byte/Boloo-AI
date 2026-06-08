import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/assessment_provider.dart';
import '../../models/message.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assessmentProvider.notifier).startAssessment();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendAnswer() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    FocusScope.of(context).unfocus();
    await ref.read(assessmentProvider.notifier).sendAnswer(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);

    // Navigate to result when complete
    ref.listen(assessmentProvider, (prev, next) {
      if (next.status == AssessmentStatus.complete && next.result != null) {
        context.go('/assessment-result');
      }
    });

    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _MayaAvatar(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Maya', style: AppTypography.h3),
                Text(
                  'Personalized Assessment',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (state.status != AssessmentStatus.scoring)
            _ProgressIndicator(
              current: state.userMessageCount,
              total: 4,
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.status == AssessmentStatus.scoring)
            _ScoringBanner(),
          Expanded(
            child: state.messages.isEmpty
                ? _buildEmptyState(state)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppDimensions.md),
                    itemCount: state.messages.length + (state.isMayaTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: state.messages[index]);
                    },
                  ),
          ),
          _buildInput(state),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AssessmentState state) {
    if (state.status == AssessmentStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
                  color: AppColors.textTertiary, size: 52),
              const SizedBox(height: AppDimensions.lg),
              const Text('Could not reach Maya', style: AppTypography.h2),
              const SizedBox(height: AppDimensions.sm),
              Text(
                state.error?.replaceFirst('ConversationException: ', '') ??
                    'Please check your internet connection and try again.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(assessmentProvider.notifier).reset();
                    Future.microtask(
                        () => ref.read(assessmentProvider.notifier).startAssessment());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                  child: const Text('Try Again',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MayaAvatar(size: 64),
          SizedBox(height: 24),
          Text('Maya is preparing your assessment...', style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _buildInput(AssessmentState state) {
    final isActive = state.status == AssessmentStatus.active;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg800,
        border: Border(top: BorderSide(color: AppColors.bg600)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.sm, AppDimensions.md, AppDimensions.md,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                enabled: isActive,
                style: AppTypography.bodyLarge,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: isActive
                      ? 'Type your answer...'
                      : state.isScoring
                          ? 'Analyzing your responses...'
                          : 'Please wait...',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bg700,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                ),
                onSubmitted: isActive ? (_) => _sendAnswer() : null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isActive ? _sendAnswer : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.brandPurple, AppColors.teal],
                        )
                      : null,
                  color: isActive ? null : AppColors.bg600,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: isActive ? Colors.white : AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: List.generate(total, (i) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < current ? AppColors.brandPurple : AppColors.bg500,
            ),
          );
        }),
      ),
    );
  }
}

class _ScoringBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandPurple.withOpacity(0.15),
            AppColors.teal.withOpacity(0.1),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.brandPurple, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.lightPurple),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Maya is building your personalized analysis...',
            style: AppTypography.caption.copyWith(color: AppColors.lightPurple),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _MayaAvatar(size: 28),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.brandPurple : AppColors.bg700,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyLarge.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MayaAvatar extends StatelessWidget {
  const _MayaAvatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
          'M',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: size * 0.45,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _MayaAvatar(size: 28),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.bg700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final opacity = ((_controller.value * 3) - i).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
