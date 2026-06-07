import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/phone_auth_screen.dart';
import '../features/auth/email_auth_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/meet_maya_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/conversation/session_setup_screen.dart';
import '../features/conversation/voice_session_screen.dart';
import '../features/conversation/text_session_screen.dart';
import '../features/conversation/scorecard_screen.dart';
import '../features/journey/journey_map_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../models/score.dart';
import '../models/conversation.dart';

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier();
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isAuth = user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isAuth && !isAuthRoute) return '/auth';
      if (isAuth && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(path: '/auth/email', builder: (_, __) => const EmailAuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFlow()),
      GoRoute(path: '/meet-maya', builder: (_, __) => const MeetMayaScreen()),
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
      GoRoute(path: '/session/setup', builder: (_, __) => const SessionSetupScreen()),
      GoRoute(
        path: '/session/voice/:conversationId',
        builder: (_, state) => VoiceSessionScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      GoRoute(
        path: '/session/text/:conversationId',
        builder: (_, state) => TextSessionScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
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
      bottomNavigationBar: BottomNavBar(location: GoRouterState.of(context).matchedLocation),
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
      (icon: Icons.map_outlined, label: 'Journey', path: '/journey'),
      (icon: Icons.bar_chart_rounded, label: 'Progress', path: '/progress'),
      (icon: Icons.person_outline_rounded, label: 'Profile', path: '/profile'),
    ];

    final currentIndex = items.indexWhere((i) => location.startsWith(i.path));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111113),
        border: Border(top: BorderSide(color: Color(0xFF32323C), width: 1)),
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
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF71717A),
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
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF71717A),
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
