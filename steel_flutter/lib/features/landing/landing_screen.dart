import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/steel_forge_button.dart';
import '../../shared/widgets/steel_glass_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _features = <_FeatureSpec>[
    _FeatureSpec(
      icon: Icons.trending_up_rounded,
      title: 'Progressive Overload',
      description: "Every session harder than the last. That's the only rule.",
    ),
    _FeatureSpec(
      icon: Icons.bolt_rounded,
      title: 'Tactical Programming',
      description:
          'Plans built around your lifts, your schedule, your weak points.',
    ),
    _FeatureSpec(
      icon: Icons.bar_chart_rounded,
      title: 'No Bullshit Tracking',
      description: "Log what matters. See what's working. Cut the rest.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TaglinePill(),
                  const SizedBox(height: 24),
                  const _HeroTitle(),
                  const SizedBox(height: 16),
                  Text(
                    'NO EXCUSES. NO HAND-HOLDING. BUILD SOMETHING REAL.',
                    textAlign: TextAlign.center,
                    style: steelMonoStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ..._features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SteelGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(f.icon, size: 22, color: SteelOpsColors.forge),
                            const SizedBox(height: 12),
                            Text(
                              f.title.toUpperCase(),
                              style: steelHeadingStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              f.description,
                              style: steelMonoStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                                color: SteelOpsColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SteelForgeButton(
                    label: 'Start Training',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.goNamed(SteelRoutes.login),
                  ),
                  const SizedBox(height: 12),
                  SteelGhostButton(
                    label: 'Sign In',
                    onPressed: () => context.goNamed(SteelRoutes.login),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'BUILT FOR THOSE WHO SHOW UP',
                    textAlign: TextAlign.center,
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.inkDim,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaglinePill extends StatelessWidget {
  const _TaglinePill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SteelOpsColors.taglineBg,
          border: Border.all(color: SteelOpsColors.taglineBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'STEEL FORGES STEEL',
            style: steelMonoStyle(
              fontSize: 11,
              color: SteelOpsColors.forgeHover,
              letterSpacing: 2.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    final base = steelHeadingStyle(
      fontSize: 56,
      fontWeight: FontWeight.w900,
      height: 0.95,
    );
    final forge = base.copyWith(
      color: SteelOpsColors.forge,
      shadows: const [
        Shadow(
          color: SteelOpsColors.forgeGlow,
          blurRadius: 40,
        ),
      ],
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'STEAL\n'),
          TextSpan(text: 'FORGES\n', style: forge),
          const TextSpan(text: 'STEEL'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureSpec {
  const _FeatureSpec({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
