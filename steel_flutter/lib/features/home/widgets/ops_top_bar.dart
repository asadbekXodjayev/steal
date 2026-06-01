import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';

class OpsTopBar extends StatelessWidget {
  const OpsTopBar({
    super.key,
    required this.operatorInitial,
    this.onProfileTap,
  });

  final String operatorInitial;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'STEEL',
                    style: steelHeadingStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: SteelOpsColors.forge,
                      letterSpacing: 3,
                    ),
                  ),
                  TextSpan(
                    text: '  |  ',
                    style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.inkDim),
                  ),
                  TextSpan(
                    text: 'THERAPY',
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.inkMid,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: SteelOpsColors.surfaceElevated,
            shape: const CircleBorder(
              side: BorderSide(color: SteelOpsColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onProfileTap,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    operatorInitial.isEmpty ? '?' : operatorInitial[0].toUpperCase(),
                    style: steelHeadingStyle(
                      fontSize: 20,
                      color: SteelOpsColors.forge,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
