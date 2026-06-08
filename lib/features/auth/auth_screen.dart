import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/boloo_button.dart';
import '../../shared/widgets/maya_avatar.dart';

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
      backgroundColor: AppColors.bgPage,
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
        const MayaAvatar(state: MayaState.idle, size: 88),
        const SizedBox(height: AppDimensions.lg),
        const Text(
          'Speak With Confidence.',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Unlock Opportunities.',
          style: AppTypography.h2.copyWith(color: AppColors.blue),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Your AI communication coach for\njobs, freelancing & career growth.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTrustRow(),
      ],
    );
  }

  Widget _buildTrustRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_rounded, color: AppColors.blue, size: 16),
          const SizedBox(width: 6),
          Text(
            '1,200+ Bangladeshis improving their English',
            style: AppTypography.caption.copyWith(color: AppColors.blue),
          ),
        ],
      ),
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
