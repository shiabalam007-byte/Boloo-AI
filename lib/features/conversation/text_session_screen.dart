import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/conversation_provider.dart';
import '../../models/message.dart';

class TextSessionScreen extends ConsumerStatefulWidget {
  const TextSessionScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<TextSessionScreen> createState() => _TextSessionScreenState();
}

class _TextSessionScreenState extends ConsumerState<TextSessionScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sessionEnding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialGreeting());
  }

  Future<void> _sendInitialGreeting() async {
    await ref
        .read(activeConversationProvider.notifier)
        .sendUserMessage('[SESSION_START]');
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    await ref.read(activeConversationProvider.notifier).sendUserMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _endSession() async {
    if (_sessionEnding) return;
    setState(() => _sessionEnding = true);

    final scores =
        await ref.read(activeConversationProvider.notifier).endSession();
    final convo = ref.read(activeConversationProvider).conversation;
    ref.read(activeConversationProvider.notifier).clearSession();

    if (mounted) {
      context.go('/scorecard', extra: {'scores': scores, 'conversation': convo});
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeConversationProvider);

    final displayMessages = state.messages
        .where((m) => m.content != '[SESSION_START]')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maya', style: AppTypography.h3),
                Text(
                  state.conversation?.topic ?? 'Practice Session',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _sessionEnding ? null : _endSession,
            child: Text(
              'End',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: displayMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppDimensions.md),
                    itemCount: displayMessages.length +
                        (state.isMayaTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayMessages.length) {
                        return const _TypingBubble();
                      }
                      return _ChatBubble(message: displayMessages[index]);
                    },
                  ),
          ),
          _buildInputBar(state.isMayaTyping),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.brandPurple,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text('Maya is preparing...', style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isMayaTyping) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg800,
        border: Border(top: BorderSide(color: AppColors.bg500)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                style: AppTypography.bodyLarge,
                enabled: !isMayaTyping,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: isMayaTyping
                      ? 'Maya is replying...'
                      : 'Type your message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.mdMinus,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            GestureDetector(
              onTap: isMayaTyping ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isMayaTyping
                      ? AppColors.bg600
                      : AppColors.brandPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: isMayaTyping ? AppColors.textTertiary : Colors.white,
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.mdMinus,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
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
          Container(
            width: 28,
            height: 28,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
                final t = _controller.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final opacity = (t * 3 - i).clamp(0.0, 1.0);
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
