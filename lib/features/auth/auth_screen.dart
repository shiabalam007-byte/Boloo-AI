import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/auth_provider.dart';

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
      body: Stack(
        children: [
          // Background decorative glow — top-right brandPurple
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPurple.withOpacity(0.12),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // Background decorative glow — bottom-left blue
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
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
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // BOLOO "B" rounded logo — gradient blue → brandPurple
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.blue, AppColors.brandPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPurple.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        const Text(
          'Speak With Confidence.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        const Text(
          'Unlock better jobs, interviews,\nfreelancing & career growth.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildSocialProofStrip(),
      ],
    );
  }

  Widget _buildSocialProofStrip() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          '⭐⭐⭐⭐⭐',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'Trusted by 1,200+ professionals in Bangladesh',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google button — gradient purple glow
        GestureDetector(
          onTap: _isLoading ? null : _signInWithGoogle,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppDimensions.mdMinus),
        // Phone button — outlined transparent
        GestureDetector(
          onTap: () => context.push('/auth/phone'),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF334155),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Continue with Phone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Center(
          child: TextButton(
            onPressed: () => context.push('/auth/email'),
            child: const Text(
              'Use email instead',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        const Center(
          child: Text(
            'By continuing, you agree to our Terms & Privacy Policy',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
