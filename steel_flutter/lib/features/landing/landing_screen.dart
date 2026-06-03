import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:steel/l10n/app_localizations.dart';

import '../../core/router.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/steel_forge_button.dart';
import '../../shared/widgets/steel_glass_card.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);

    final features = <_FeatureSpec>[
      _FeatureSpec(
        icon: Icons.trending_up_rounded,
        title: t('landing.FEATURE_1_TITLE'),
        description: t('landing.FEATURE_1_DESC'),
      ),
      _FeatureSpec(
        icon: Icons.bolt_rounded,
        title: t('landing.FEATURE_2_TITLE'),
        description: t('landing.FEATURE_2_DESC'),
      ),
      _FeatureSpec(
        icon: Icons.bar_chart_rounded,
        title: t('landing.FEATURE_3_TITLE'),
        description: t('landing.FEATURE_3_DESC'),
      ),
    ];

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
                  _TaglinePill(label: t('landing.TAGLINE')),
                  const SizedBox(height: 24),
                  _HeroTitle(
                    line1: t('landing.HERO_LINE_1'),
                    line2: t('landing.HERO_LINE_2'),
                    line3: t('landing.HERO_LINE_3'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('landing.HERO_DESC'),
                    textAlign: TextAlign.center,
                    style: steelMonoStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...features.map(
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
                    label: t('landing.START_TRAINING'),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.goNamed(SteelRoutes.login),
                  ),
                  const SizedBox(height: 12),
                  SteelGhostButton(
                    label: t('landing.SIGN_IN'),
                    onPressed: () => context.goNamed(SteelRoutes.login),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t('landing.FOOTER'),
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
  const _TaglinePill({required this.label});

  final String label;

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
            label,
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
  const _HeroTitle({
    required this.line1,
    required this.line2,
    required this.line3,
  });

  final String line1;
  final String line2;
  final String line3;

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
          TextSpan(text: '$line1\n'),
          TextSpan(text: '$line2\n', style: forge),
          TextSpan(text: line3),
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
