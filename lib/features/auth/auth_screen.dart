import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/boloo_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              const Spacer(),
              _buildHeroSection(),
              const Spacer(),
              _buildAuthButtons(),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandPurple, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(
            child: Text(
              'B',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        const Text(
          'Speak With Confidence.',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Unlock Opportunities.',
          style: AppTypography.h2.copyWith(color: AppColors.lightPurple),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Your AI communication coach for\njobs, freelancing & career growth.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        BoolooButton.primary(
          label: 'Continue with Google',
          prefixIcon: Icons.g_mobiledata_rounded,
          onPressed: _isLoading ? null : _signInWithGoogle,
          isLoading: _isLoading,
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        BoolooButton.secondary(
          label: 'Continue with Phone',
          prefixIcon: Icons.phone_outlined,
          onPressed: () => context.push('/auth/phone'),
        ),
        const SizedBox(height: AppDimensions.md),
        TextButton(
          onPressed: () => context.push('/auth/email'),
          child: Text(
            'Use email instead',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'By continuing, you agree to our Terms & Privacy Policy',
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
