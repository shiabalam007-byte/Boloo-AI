import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/boloo_button.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _phone;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = '+880${_phoneController.text.trim()}';
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithPhone(phone);
      setState(() {
        _otpSent = true;
        _phone = phone;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_phone == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).verifyPhoneOtp(
        _phone!,
        _otpController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _otpSent ? 'Enter OTP' : 'Phone Login',
          style: AppTypography.h3,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.lg),
            if (!_otpSent) ...[
              Text('Your phone number', style: AppTypography.h2),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'We will send you a verification code',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppDimensions.xl),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.mdMinus,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bg600,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.bg500),
                    ),
                    child: Text('+880', style: AppTypography.bodyLarge),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      style: AppTypography.bodyLarge,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        hintText: '01XXXXXXXXX',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              BoolooButton.primary(
                label: 'Send OTP',
                onPressed: _isLoading ? null : _sendOtp,
                isLoading: _isLoading,
              ),
            ] else ...[
              Text('Enter verification code', style: AppTypography.h2),
              const SizedBox(height: AppDimensions.sm),
              Text('Sent to $_phone', style: AppTypography.body),
              const SizedBox(height: AppDimensions.xl),
              TextField(
                controller: _otpController,
                style: AppTypography.h2.copyWith(
                  letterSpacing: 8,
                  fontFamily: 'DMMonoMedium',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              BoolooButton.primary(
                label: 'Verify',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppDimensions.md),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Change phone number'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
