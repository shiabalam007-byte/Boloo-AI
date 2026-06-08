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
import '../../shared/widgets/boloo_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

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
                context.go('/dashboard');
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
    return Scaffold(
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.canPop() ? context.pop() : context.go('/auth');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.xl),
            _buildFeatures(),
            const SizedBox(height: AppDimensions.xl),
            _buildPriceCard(),
            const SizedBox(height: AppDimensions.xl),
            _buildPaymentMethods(),
            const SizedBox(height: AppDimensions.xl),
            BoolooButton.primary(
              label: 'Start My Journey — ৳1,999',
              onPressed: _isLoading ? null : _purchaseNow,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppDimensions.md),
            Center(
              child: Text(
                '🔒 Secure payment via Zinnipay',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
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
            color: AppColors.brandPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '🚀 30-Day Career Accelerator',
            style: AppTypography.caption.copyWith(color: AppColors.lightPurple),
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

  Widget _buildFeatures() {
    const features = [
      ('🤖', '30 AI-Powered Sessions', 'Daily practice with Maya, your personal coach'),
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
        gradient: LinearGradient(
          colors: [
            AppColors.brandPurple.withOpacity(0.2),
            AppColors.teal.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusHero),
        border: Border.all(color: AppColors.brandPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Founding Member Offer',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳',
                style: AppTypography.h2.copyWith(color: AppColors.lightPurple),
              ),
              Text('1,999', style: AppTypography.displayXL.copyWith(
                color: AppColors.textPrimary,
              )),
            ],
          ),
          Text(
            'Was ৳2,999 — Limited Time',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '90 Days Full Access',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accepted payments', style: AppTypography.caption),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: ['bKash', 'Nagad', 'Visa', 'MasterCard'].map((m) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bg600,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bg500),
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
          if (request.url.startsWith('boloo://payment/return')) {
            widget.onSuccess();
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('boloo://payment/cancel')) {
            widget.onCancel();
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
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
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
