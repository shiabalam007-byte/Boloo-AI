import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/maya_avatar.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;
  bool _confirmingPayment = false;

  Future<void> _purchaseNow() async {
    final user = ref.read(currentUserProvider);
    final profile = ref.read(userProfileNotifierProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(paymentServiceProvider).initiatePayment(
        userId: user.id,
        userName: profile?.fullName ?? 'User',
        userEmail: user.email ?? '',
        userPhone: profile?.phone,
      );

      if (!mounted) return;
      final paymentUrl = result['payment_url'] as String?;
      if (paymentUrl != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebView(
              url: paymentUrl,
              onSuccess: () {
                Navigator.of(context).pop();
                if (!mounted) return;
                setState(() => _confirmingPayment = true);
                ref.invalidate(subscriptionProvider);
                Future.delayed(const Duration(seconds: 10), () {
                  if (mounted && _confirmingPayment) context.go('/dashboard');
                });
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiation failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(hasSubscriptionProvider, (prev, next) {
      if (_confirmingPayment && next.value == true && mounted) {
        context.go('/dashboard');
      }
    });

    final profile = ref.watch(userProfileNotifierProvider).value;
    final assessmentResult = profile?.assessmentResult;
    final opportunity = assessmentResult?['biggest_opportunity'] as String?;
    final recommendation = assessmentResult?['recommendation'] as String?;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.canPop() ? context.pop() : context.go('/auth');
          },
        ),
      ),
      body: Stack(
        children: [
          // Scrollable content — padded at bottom so it clears the sticky bar
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMayaSection(opportunity, recommendation),
                const SizedBox(height: AppDimensions.sm),
                _buildSocialProof(),
                const SizedBox(height: AppDimensions.lg),
                _buildHeader(),
                const SizedBox(height: AppDimensions.lg),
                _buildTransformationStory(),
                const SizedBox(height: AppDimensions.xl),
                _buildFeatures(),
                const SizedBox(height: AppDimensions.xl),
                _buildPriceCard(),
                const SizedBox(height: AppDimensions.xl),
                _buildPaymentMethods(),
                const SizedBox(height: AppDimensions.xl),
                // Ghost CTA — points user upward to sticky bar
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _purchaseNow,
                    child: Text(
                      'or pay at the bottom ↑',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Center(
                  child: Text(
                    '🔒 Secure payment via Zinnipay',
                    style: AppTypography.caption,
                  ),
                ),
                // Extra bottom padding so content scrolls above the sticky bar
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_confirmingPayment)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Confirming your payment...',
                        style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait a moment.',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Sticky bottom CTA bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  border: const Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue, AppColors.brandPurple],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _purchaseNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Start My Journey →',
                                  style: AppTypography.h3.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳22/day',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMayaSection(String? opportunity, String? recommendation) {
    final displayText = recommendation ??
        opportunity ??
        "I've analyzed your goals. Here's your personalized 90-day plan.";

    return Column(
      children: [
        const Center(child: MayaAvatar(state: MayaState.idle, size: 80)),
        const SizedBox(height: AppDimensions.md),
        Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maya says',
                style: AppTypography.caption.copyWith(color: AppColors.blue),
              ),
              const SizedBox(height: 4),
              Text(displayText, style: AppTypography.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProof() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '★★★★★',
            style: AppTypography.caption.copyWith(color: AppColors.success),
          ),
          Text(
            '4.9 Rating',
            style: AppTypography.micro.copyWith(color: AppColors.success),
          ),
          Text(
            '|',
            style: AppTypography.caption.copyWith(
              color: AppColors.success.withOpacity(0.4),
            ),
          ),
          Text(
            '1,247 enrolled',
            style: AppTypography.micro.copyWith(color: AppColors.success),
          ),
          Text(
            '|',
            style: AppTypography.caption.copyWith(
              color: AppColors.success.withOpacity(0.4),
            ),
          ),
          Text(
            'Bangladesh #1',
            style: AppTypography.micro.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '🚀 90-Day Career Accelerator',
            style: AppTypography.caption.copyWith(color: AppColors.blue),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        const Text('Unlock Your Full\nPotential', style: AppTypography.displayL),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Join 1,200+ confident Bangladeshi professionals who transformed their English communication.',
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildTransformationStory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What changes for you:', style: AppTypography.h3),
        const SizedBox(height: AppDimensions.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Before card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface2,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '😔 Before BOLOO',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ...[
                      'Fear of speaking English',
                      'Missed career chances',
                      'Low confidence at work',
                    ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $item',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            // After card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ After BOLOO',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ...[
                      'Speak English confidently',
                      'Land better opportunities',
                      'Lead meetings with ease',
                    ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $item',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    const features = [
      ('🤖', '90 AI-Powered Sessions', 'Daily practice with Maya, your personal coach'),
      ('🎯', 'Career-Focused Topics', 'Interviews, freelancing, corporate communication'),
      ('📊', 'Real Progress Scores', 'Confidence, fluency & communication scores'),
      ('🗣️', 'Voice + Text Practice', 'Speak or type — practice your way'),
      ('🔥', 'Streak System', 'Stay motivated with daily streaks'),
      ('🇧🇩', 'Bangla + English', 'Mixed mode for comfortable learning'),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.$1, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.$2, style: AppTypography.h3),
                  Text(f.$3, style: AppTypography.body),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPriceCard() {
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
          Text(
            'Founding Member Offer',
            style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳',
                style: AppTypography.h2.copyWith(color: Colors.white.withOpacity(0.85)),
              ),
              Text('1,999', style: AppTypography.displayXL.copyWith(
                color: Colors.white,
              )),
            ],
          ),
          Text(
            'Was ৳2,999 — Limited Time',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.6),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '90 Days Full Access',
            style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accepted payments', style: AppTypography.caption),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: ['bKash', 'Nagad', 'Visa', 'MasterCard'].map((m) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(m, style: AppTypography.micro.copyWith(
              color: AppColors.textSecondary,
            )),
          )).toList(),
        ),
      ],
    );
  }
}

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({
    super.key,
    required this.url,
    required this.onSuccess,
    required this.onCancel,
  });

  final String url;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          // ZiniPay redirects to the Supabase payment-return function
          if (request.url.contains('/payment-return')) {
            final uri = Uri.tryParse(request.url);
            final status = uri?.queryParameters['status'] ?? 'cancel';
            if (status == 'success') {
              widget.onSuccess();
            } else {
              widget.onCancel();
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        title: const Text('Complete Payment', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: widget.onCancel,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
