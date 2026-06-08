import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/user_provider.dart';
import '../providers/subscription_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/phone_auth_screen.dart';
import '../features/auth/email_auth_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/maya_welcome_screen.dart';
import '../features/assessment/assessment_screen.dart';
import '../features/assessment/assessment_result_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/conversation/voice_session_screen.dart';
import '../features/conversation/scorecard_screen.dart';
import '../features/journey/journey_map_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../models/conversation.dart';

class _AppGateNotifier extends ChangeNotifier {
  _AppGateNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription _sub;

  void refresh() => notifyListeners();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// Routes accessible without a subscription
const _kFreeRoutes = [
  '/onboarding',
  '/maya-welcome',
  '/assessment',
  '/assessment-result',
  '/paywall',
  '/settings',
  '/splash',
];

final routerProvider = Provider<GoRouter>((ref) {
  final gateNotifier = _AppGateNotifier();
  ref.onDispose(gateNotifier.dispose);

  ref.listen(userProfileNotifierProvider, (_, __) => gateNotifier.refresh());
  ref.listen(hasSubscriptionProvider, (_, __) => gateNotifier.refresh());

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: gateNotifier,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isAuth = user != null;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;

      // Not authenticated → auth
      if (!isAuth) {
        return loc.startsWith('/auth') ? null : '/auth';
      }

      // Authenticated user on auth route → decide destination
      if (loc.startsWith('/auth')) {
        final profileAsync = ref.read(userProfileNotifierProvider);

        // Profile still loading — stay on a neutral path until resolved
        if (profileAsync.isLoading) return '/splash';

        final profile = profileAsync.value;
        if (profile == null) return '/onboarding';

        if (!profile.onboardingCompleted) return '/onboarding';

        final hasSub = ref.read(hasSubscriptionProvider).value ?? false;
        if (!profile.assessmentCompleted && !hasSub) return '/maya-welcome';
        return hasSub ? '/dashboard' : '/paywall';
      }

      // Free routes — always allow
      if (_kFreeRoutes.any((r) => loc.startsWith(r))) return null;

      // Protected routes — gate check
      final profileAsync = ref.read(userProfileNotifierProvider);
      if (profileAsync.isLoading) return null; // let it load, don't bounce

      final profile = profileAsync.value;
      if (profile != null && !profile.onboardingCompleted) return '/onboarding';

      final hasSubAsync = ref.read(hasSubscriptionProvider);
      final isSubscribed = hasSubAsync.hasValue && hasSubAsync.value == true;

      if (profile != null && !profile.assessmentCompleted && !isSubscribed) {
        return '/maya-welcome';
      }

      if (hasSubAsync.hasValue && hasSubAsync.value == false) return '/paywall';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(path: '/auth/email', builder: (_, __) => const EmailAuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFlow()),
      GoRoute(path: '/maya-welcome', builder: (_, __) => const MayaWelcomeScreen()),
      GoRoute(path: '/assessment', builder: (_, __) => const AssessmentScreen()),
      GoRoute(path: '/assessment-result', builder: (_, __) => const AssessmentResultScreen()),
      GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/journey', builder: (_, __) => const JourneyMapScreen()),
          GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/session/voice',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VoiceSessionScreen(sessionConfig: extra ?? const {});
        },
      ),
      GoRoute(
        path: '/scorecard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ScorecardScreen(
            scores: extra?['scores'] as Map<String, dynamic>?,
            conversation: extra?['conversation'] as Conversation?,
          );
        },
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        location: GoRouterState.of(context).matchedLocation,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_rounded, label: 'Home', path: '/dashboard'),
      (icon: Icons.mic_rounded, label: 'Practice', path: '/journey'),
      (icon: Icons.bar_chart_rounded, label: 'Progress', path: '/progress'),
      (icon: Icons.person_outline_rounded, label: 'Profile', path: '/profile'),
    ];

    final currentIndex = items.indexWhere((i) => location.startsWith(i.path));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(item.path),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
