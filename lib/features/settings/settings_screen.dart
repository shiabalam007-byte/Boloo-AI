import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../core/constants/storage_keys.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

const _kPrivacyPolicyUrl = 'https://boolooai.com/privacy';
const _kTermsUrl = 'https://boolooai.com/terms';
const _kFaqUrl = 'https://boolooai.com/faq';
const _kSupportEmail = 'support@boolooai.com';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled =
          prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
      _soundEnabled = prefs.getBool(StorageKeys.soundEnabled) ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _editName(String? currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg700,
        title: const Text('Edit Name', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          style: AppTypography.bodyLarge,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && result.isNotEmpty) {
      await ref.read(userProfileNotifierProvider.notifier).updateProfile({
        'full_name': result,
      });
    }
  }

  Future<void> _editDailyGoal(int current) async {
    int selected = current;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bg700,
          title: const Text('Daily Goal', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [10, 15, 20, 30].map((min) => RadioListTile<int>(
              value: min,
              groupValue: selected,
              onChanged: (v) => setDialogState(() => selected = v!),
              activeColor: AppColors.brandPurple,
              title: Text('$min minutes/day', style: AppTypography.bodyLarge),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await ref.read(userProfileNotifierProvider.notifier).updateProfile({
        'daily_commitment_min': result,
      });
    }
  }

  void _openWebPage(BuildContext context, String title, String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _WebPageScreen(title: title, url: url),
    ));
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg700,
        title: const Text('Contact Support', style: AppTypography.h3),
        content: Text(
          'Email us at $_kSupportEmail\n\nWe respond within 24 hours.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg700,
        title: const Text('Sign Out', style: AppTypography.h3),
        content: const Text(
          'Are you sure you want to sign out?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final profile = profileAsync.value;

    return Scaffold(
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: AppTypography.h3),
      ),
      body: ListView(
        children: [
          _Section(
            title: 'Account',
            children: [
              _ListTile(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                value: profile?.fullName,
                onTap: () => _editName(profile?.fullName),
              ),
              _ListTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: ref.read(currentUserProvider)?.email,
              ),
            ],
          ),
          _Section(
            title: 'Learning',
            children: [
              _ListTile(
                icon: Icons.timer_outlined,
                label: 'Daily Goal',
                value: '${profile?.dailyCommitmentMin ?? 15} min/day',
                onTap: () => _editDailyGoal(profile?.dailyCommitmentMin ?? 15),
              ),
              _SwitchTile(
                icon: Icons.notifications_outlined,
                label: 'Daily Reminders',
                value: _notificationsEnabled,
                onChanged: (v) {
                  setState(() => _notificationsEnabled = v);
                  _savePreference(StorageKeys.notificationsEnabled, v);
                },
              ),
              _SwitchTile(
                icon: Icons.volume_up_outlined,
                label: 'Maya Voice',
                value: _soundEnabled,
                onChanged: (v) {
                  setState(() => _soundEnabled = v);
                  _savePreference(StorageKeys.soundEnabled, v);
                },
              ),
            ],
          ),
          _Section(
            title: 'Subscription',
            children: [
              _ListTile(
                icon: Icons.card_membership_outlined,
                label: 'Manage Subscription',
                onTap: () => _openWebPage(context, 'Manage Subscription', _kPrivacyPolicyUrl),
              ),
            ],
          ),
          _Section(
            title: 'Support',
            children: [
              _ListTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _openWebPage(context, 'Help & FAQ', _kFaqUrl),
              ),
              _ListTile(
                icon: Icons.email_outlined,
                label: 'Contact Support',
                onTap: () => _contactSupport(context),
              ),
            ],
          ),
          _Section(
            title: 'Legal',
            children: [
              _ListTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _openWebPage(context, 'Privacy Policy', _kPrivacyPolicyUrl),
              ),
              _ListTile(
                icon: Icons.article_outlined,
                label: 'Terms of Service',
                onTap: () => _openWebPage(context, 'Terms of Service', _kTermsUrl),
              ),
            ],
          ),
          _Section(
            title: 'Danger Zone',
            children: [
              _ListTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                labelColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: _signOut,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Text(
              'BOLOO AI v1.0.0\nSpeak With Confidence. Unlock Opportunities.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.lg,
            AppDimensions.lg,
            AppDimensions.lg,
            AppDimensions.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.bg700,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.bg500),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.label,
    this.value,
    this.labelColor,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.mdMinus,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value!, style: AppTypography.body),
              const SizedBox(width: 4),
            ],
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }
}

class _WebPageScreen extends StatefulWidget {
  const _WebPageScreen({required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<_WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<_WebPageScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg900,
      appBar: AppBar(
        backgroundColor: AppColors.bg900,
        title: Text(widget.title, style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppDimensions.md),
          Expanded(child: Text(label, style: AppTypography.bodyLarge)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandPurple,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.brandPurple.withOpacity(0.3);
              }
              return AppColors.bg500;
            }),
          ),
        ],
      ),
    );
  }
}
