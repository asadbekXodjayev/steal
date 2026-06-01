import 'package:flutter/material.dart';

/// Max width for form/content on tablets; phones use full width inside padding.
const double kSteelMaxContentWidth = 420;

/// Horizontal padding tuned for Android gesture navigation and notched devices.
const EdgeInsets kSteelScreenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

class SteelScreenBody extends StatelessWidget {
  const SteelScreenBody({
    super.key,
    required this.child,
    this.maxWidth = kSteelMaxContentWidth,
    this.padding = kSteelScreenPadding,
    this.center = true,
    this.scrollable = false,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  final bool center;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (scrollable) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: center
                  ? Center(child: content)
                  : Align(alignment: Alignment.topCenter, child: content),
            ),
          );
        },
      );
    }

    if (center) {
      return Center(child: content);
    }
    return Align(alignment: Alignment.topCenter, child: content);
  }
}
