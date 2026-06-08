import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boloo_ai/shared/widgets/maya_avatar.dart';
import 'package:boloo_ai/app/theme/colors.dart';
import 'package:boloo_ai/app/theme/typography.dart';
import 'package:boloo_ai/app/theme/dimensions.dart';

void main() {
  group('Maya Avatar States', () {
    for (final state in MayaState.values) {
      testWidgets('MayaAvatar - ${state.name}', (tester) async {
        tester.view.physicalSize = const Size(390, 390);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(
                primary: AppColors.blue,
              ),
            ),
            home: Scaffold(
              backgroundColor: AppColors.bgPage,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MayaAvatar(state: state, size: 100),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/maya_${state.name}.png'),
        );
      });
    }
  });

  group('Auth Screen Layout', () {
    testWidgets('auth screen visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _AuthScreenMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_auth.png'),
      );
    });
  });

  group('Dashboard Screen Layout', () {
    testWidgets('dashboard visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _DashboardMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_dashboard.png'),
      );
    });
  });

  group('Maya Welcome Screen Layout', () {
    testWidgets('maya welcome visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _MayaWelcomeMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_maya_welcome.png'),
      );
    });
  });

  group('Assessment Screen Layout', () {
    testWidgets('assessment visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _AssessmentMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_assessment.png'),
      );
    });
  });

  group('Voice Session Screen Layout', () {
    testWidgets('voice session visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _VoiceSessionMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_voice_session.png'),
      );
    });
  });

  group('Paywall Screen Layout', () {
    testWidgets('paywall visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _PaywallMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_paywall.png'),
      );
    });
  });

  group('Journey Map Screen Layout', () {
    testWidgets('journey map visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: _JourneyMapMock(),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screen_journey.png'),
      );
    });
  });
}

// ─── Mock Screens ────────────────────────────────────────────────────────────

class _AuthScreenMock extends StatelessWidget {
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
              const MayaAvatar(state: MayaState.idle, size: 88),
              const SizedBox(height: AppDimensions.lg),
              Text('BOLOO AI', style: AppTypography.displayL.copyWith(color: AppColors.blue)),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Your AI-powered English\ncoach for career success',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildPrimaryButton(context, 'Continue with Google', AppColors.blue),
              const SizedBox(height: AppDimensions.sm),
              _buildPrimaryButton(context, 'Continue with Email', AppColors.bgSurface,
                  textColor: AppColors.textPrimary, border: true),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String label, Color bg,
      {Color textColor = Colors.white, bool border = false}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: border ? Border.all(color: AppColors.borderSubtle) : null,
        boxShadow: border ? null : [
          BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(label, style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        )),
      ),
    );
  }
}

class _DashboardMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPage,
            elevation: 0,
            title: Row(
              children: [
                Text('BOLOO', style: AppTypography.h2.copyWith(color: AppColors.blue)),
                Text(' AI', style: AppTypography.h2),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Day 1', style: AppTypography.caption.copyWith(color: AppColors.blue)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text('3', style: AppTypography.caption.copyWith(
                        color: AppColors.warning, fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Maya Hero Card
                Container(
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
                        blurRadius: 24, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const MayaAvatar(state: MayaState.idle, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning, Alex!',
                              style: AppTypography.bodyLarge.copyWith(color: Colors.white)),
                            const SizedBox(height: 2),
                            Text("Ready for Day 1? Let's practice!",
                              style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.85))),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Score Cards
                Row(
                  children: [
                    _scoreChip('Confidence', 78),
                    const SizedBox(width: 8),
                    _scoreChip('Fluency', 72),
                    const SizedBox(width: 8),
                    _scoreChip('Communication', 81),
                  ],
                ),
                const SizedBox(height: 12),
                // Today's Challenge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text('1',
                          style: const TextStyle(fontFamily: 'sans-serif', fontSize: 18,
                            fontWeight: FontWeight.w700, color: AppColors.blue))),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Challenge",
                              style: TextStyle(fontSize: 11, color: AppColors.blue)),
                            Text('Introduce Yourself Professionally',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('15 min · foundation',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.blue, borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Start', style: TextStyle(fontSize: 12, color: Colors.white,
                              fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Recent Sessions', style: AppTypography.h3),
                const SizedBox(height: 8),
                _sessionCard('Job Interview Practice', 'Today · voice', 85),
                _sessionCard('Email Writing', 'Yesterday · text', 79),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: AppColors.blue,
        elevation: 4,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: const Text('Practice Now',
          style: TextStyle(fontFamily: 'sans-serif', color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _scoreChip(String label, int value) {
    final color = AppColors.scoreColor(value.toDouble());
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text('$value', style: TextStyle(
              fontFamily: 'sans-serif', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(String topic, String subtitle, int score) {
    final color = AppColors.scoreColor(score.toDouble());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.blueLight, borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Icon(Icons.mic_rounded, color: AppColors.blue, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$score', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MayaWelcomeMock extends StatelessWidget {
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
              const MayaAvatar(state: MayaState.speaking, size: 100),
              const SizedBox(height: AppDimensions.xl),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text('Maya', style: AppTypography.caption.copyWith(color: AppColors.blue)),
                    const SizedBox(height: 4),
                    Text(
                      "Hi! I'm Maya, your AI English coach. I'll help you speak with confidence. First, let me understand your goals.",
                      style: AppTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(color: AppColors.blue.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Center(
                  child: Text("Let's Begin", style: TextStyle(
                    fontFamily: 'sans-serif', color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 16,
                  )),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                children: [
                  const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Q 2 / 4', style: AppTypography.caption.copyWith(color: AppColors.brandPurple)),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
            // Maya speaking
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: MayaAvatar(state: MayaState.speaking, size: 90)),
            ),
            // Chat bubble
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                ),
                child: Text(
                  'What is your main goal for improving English?',
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            // User response area
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text('I want to get a better job and speak confidently in meetings...',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              ),
            ),
            // Mic button
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.xl),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue,
                  boxShadow: [
                    BoxShadow(color: AppColors.blue.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceSessionMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Day 1 • Introduce Yourself', style: AppTypography.h3),
                        Text('foundation', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('12:34', style: TextStyle(fontSize: 12, fontFamily: 'sans-serif')),
                  ),
                ],
              ),
            ),
            // Maya avatar
            const Expanded(
              flex: 2,
              child: Center(child: MayaAvatar(state: MayaState.speaking, size: 120)),
            ),
            // Conversation messages
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _chatBubble('Maya', "Hello! I'm Maya. Today we'll practice introducing yourself professionally.", true),
                      const SizedBox(height: 8),
                      _chatBubble('You', 'Hi, my name is Alex and I have 3 years of experience...', false),
                      const SizedBox(height: 8),
                      _chatBubble('Maya', "Great start! Let me ask about your key achievements...", true),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.bgSurface2,
                    ),
                    child: const Icon(Icons.stop_rounded, color: AppColors.textSecondary),
                  ),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.error,
                      boxShadow: [
                        BoxShadow(color: AppColors.error.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
                  ),
                  Container(
                    width: 52, height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.bgSurface2,
                    ),
                    child: const Icon(Icons.keyboard_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String speaker, String text, bool isMaya) {
    return Align(
      alignment: isMaya ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMaya ? AppColors.blueLight : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMaya ? AppColors.blue.withOpacity(0.2) : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: isMaya ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(speaker, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: isMaya ? AppColors.blue : AppColors.textSecondary,
            )),
            const SizedBox(height: 2),
            Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _PaywallMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: const Icon(Icons.close_rounded),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Maya section
            Column(
              children: [
                const Center(child: MayaAvatar(state: MayaState.idle, size: 80)),
                const SizedBox(height: 12),
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
                      Text('Maya says', style: AppTypography.caption.copyWith(color: AppColors.blue)),
                      const SizedBox(height: 4),
                      Text("You have strong potential for professional English. Your biggest opportunity is interview preparation. I've built your personalized 90-day plan.",
                        style: AppTypography.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blueLight, borderRadius: BorderRadius.circular(20),
              ),
              child: Text('🚀 90-Day Career Accelerator',
                style: AppTypography.caption.copyWith(color: AppColors.blue)),
            ),
            const SizedBox(height: 12),
            const Text('Unlock Your Full\nPotential', style: AppTypography.displayL),
            const SizedBox(height: 8),
            Text('Join 1,200+ confident Bangladeshi professionals who transformed their English.',
              style: AppTypography.body),
            const SizedBox(height: AppDimensions.xl),
            // Price card
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.brandPurple],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusHero),
              ),
              child: Column(
                children: [
                  Text('Founding Member Offer',
                    style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('৳', style: AppTypography.h2.copyWith(color: Colors.white.withOpacity(0.85))),
                      Text('1,999', style: AppTypography.displayXL.copyWith(color: Colors.white)),
                    ],
                  ),
                  Text('Was ৳2,999 — Limited Time',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      decoration: TextDecoration.lineThrough,
                    )),
                  const SizedBox(height: 4),
                  Text('90 Days Full Access',
                    style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.blue, AppColors.brandPurple]),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Center(
                child: Text('Start My Journey — ৳1,999', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyMapMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.bgPage,
            title: const Text('Your Journey', style: AppTypography.h2),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.05,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation(AppColors.brandPurple),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Day 5 / 90',
                      style: AppTypography.caption.copyWith(color: AppColors.lightPurple)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _phaseHeader('🌱 Foundation'),
                const SizedBox(height: 12),
                _dayCard(1, 'Introduce Yourself Professionally', 'completed'),
                _dayCard(2, 'Describe Your Work Experience', 'completed'),
                _dayCard(3, 'Talk About Your Skills', 'completed'),
                _dayCard(4, 'Handling Difficult Questions', 'completed'),
                _dayCard(5, 'Professional Email Phrases', 'current'),
                _dayCard(6, 'Giving Presentations', 'locked'),
                _dayCard(7, 'Negotiation Skills', 'locked'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseHeader(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(
        color: AppColors.lightPurple, fontWeight: FontWeight.w600,
      )),
    );
  }

  Widget _dayCard(int day, String title, String status) {
    final isLocked = status == 'locked';
    final isCompleted = status == 'completed';
    final isCurrent = status == 'current';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.brandPurple.withOpacity(0.15)
            : isLocked ? AppColors.bgPage : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isCurrent ? AppColors.brandPurple : AppColors.borderSubtle,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.15)
                  : isCurrent ? AppColors.brandPurple : AppColors.bgSurface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('$day', style: TextStyle(
              fontFamily: 'sans-serif', fontSize: 16, fontWeight: FontWeight.w700,
              color: isCompleted ? AppColors.success
                  : isCurrent ? Colors.white
                  : isLocked ? AppColors.textTertiary : AppColors.textSecondary,
            ))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isLocked ? AppColors.textTertiary : AppColors.textPrimary,
                )),
                Text('15 min • foundation', style: AppTypography.caption),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 18)
          else if (isCompleted)
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
          else
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        ],
      ),
    );
  }
}
