// lib/features/programs/programs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'program_detail_screen.dart';

/// Maps a PocketBase `goalType` onto a canonical category id used by the filter.
String _categoryForGoal(String goalType) {
  switch (goalType) {
    case 'strength':
      return 'STRENGTH';
    case 'fat_loss':
      return 'FAT LOSS';
    case 'endurance':
      return 'ENDURANCE';
    case 'rehabilitation':
      return 'REHAB';
    case 'muscle_building':
    default:
      return 'HYPERTROPHY';
  }
}

/// Canonical category ids (stable, language-independent) → localization keys.
const _categories = <String, String>{
  'ALL': 'programs.CAT_ALL',
  'STRENGTH': 'programs.CAT_STRENGTH',
  'HYPERTROPHY': 'programs.CAT_HYPERTROPHY',
  'FAT LOSS': 'programs.CAT_FAT_LOSS',
  'ENDURANCE': 'programs.CAT_ENDURANCE',
};

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
    final templatesAsync = ref.watch(programTemplatesProvider);
    final categoryIds = _categories.keys.toList();

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: SteelEmptyState(
              title: t('programs.COULD_NOT_LOAD'),
              subtitle: '$err',
              icon: Icons.cloud_off,
              actionLabel: t('common.RETRY'),
              onAction: () => ref.invalidate(programTemplatesProvider),
            ),
          ),
          data: (templates) {
            final filtered = _selectedCategory == 'ALL'
                ? templates
                : templates
                    .where((tpl) =>
                        _categoryForGoal(tpl.goalType) == _selectedCategory)
                    .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('programs.TITLE'),
                          style: steelHeadingStyle(
                              fontSize: 42, fontWeight: FontWeight.w900)),
                      Container(
                        width: 48,
                        height: 3,
                        margin: const EdgeInsets.only(top: 4, bottom: 6),
                        color: SteelOpsColors.orange,
                      ),
                      Text('${templates.length} ${t('programs.LEGEND_PROGRAMS')}',
                          style: steelMonoStyle(
                              fontSize: 11, color: SteelOpsColors.muted)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categoryIds.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = categoryIds[i];
                      final selected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? SteelOpsColors.orange
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: selected
                                    ? SteelOpsColors.orange
                                    : SteelOpsColors.borderStrong,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            t(_categories[cat]!),
                            style: steelMonoStyle(
                              fontSize: 11,
                              color:
                                  selected ? Colors.white : SteelOpsColors.inkMid,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(height: 1, color: SteelOpsColors.border),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: SteelEmptyState(
                            title: t('programs.NO_PROGRAMS_TITLE'),
                            subtitle: t('programs.NO_PROGRAMS_DESC'),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(programTemplatesProvider),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.58,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) => _ProgramCard(
                              template: filtered[i],
                              featured: i == 0 && _selectedCategory == 'ALL',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ProgramDetailScreen(template: filtered[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgramCard extends ConsumerWidget {
  const _ProgramCard({
    required this.template,
    required this.featured,
    required this.onTap,
  });
  final ProgramTemplate template;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(
          color: featured ? SteelOpsColors.orange : SteelOpsColors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
                child: Image.network(
                  template.image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: SteelOpsColors.surfaceElevated,
                    child: Icon(Icons.fitness_center,
                        color: SteelOpsColors.muted, size: 32),
                  ),
                ),
              ),
              if (featured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: SteelOpsColors.orange,
                    child: Text(t('programs.FEATURED'),
                        style: steelMonoStyle(
                            fontSize: 9,
                            color: Colors.white,
                            letterSpacing: 1.5)),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.athleteName.toUpperCase(),
                      style: steelMonoStyle(
                          fontSize: 9, color: SteelOpsColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(template.title,
                      style: steelHeadingStyle(
                          fontSize: 14, fontWeight: FontWeight.w800),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    template.bestFor.isNotEmpty
                        ? template.bestFor
                        : template.description,
                    style: steelMonoStyle(
                        fontSize: 9, color: SteelOpsColors.inkDim),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${template.daysPerWeek} ${t('programs.DAYS_WEEK')}  ·  ${template.sessionLength}',
                    style: steelMonoStyle(
                        fontSize: 8, color: SteelOpsColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: template.tags
                        .take(2)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: SteelOpsColors.borderStrong),
                              ),
                              child: Text(t('programs.tag.$tag'),
                                  style: steelMonoStyle(
                                      fontSize: 8,
                                      color: SteelOpsColors.inkMid,
                                      letterSpacing: 0.5)),
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            featured ? SteelOpsColors.orange : Colors.transparent,
                        border: Border.all(
                          color: featured
                              ? SteelOpsColors.orange
                              : SteelOpsColors.borderStrong,
                        ),
                      ),
                      child: Text(
                        featured ? t('programs.VIEW_PROGRAM') : t('programs.VIEW'),
                        textAlign: TextAlign.center,
                        style: steelMonoStyle(
                          fontSize: 10,
                          color:
                              featured ? Colors.white : SteelOpsColors.inkMid,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
