// lib/features/programs/programs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'program_detail_screen.dart';

/// Maps a PocketBase `goalType` onto a display category used by the filter.
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

const _categories = [
  'ALL',
  'STRENGTH',
  'HYPERTROPHY',
  'FAT LOSS',
  'ENDURANCE',
];

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(programTemplatesProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: SteelEmptyState(
              title: 'Could not load programs',
              subtitle: '$err',
              icon: Icons.cloud_off,
              actionLabel: 'RETRY',
              onAction: () => ref.invalidate(programTemplatesProvider),
            ),
          ),
          data: (templates) {
            final filtered = _selectedCategory == 'ALL'
                ? templates
                : templates
                    .where((t) => _categoryForGoal(t.goalType) == _selectedCategory)
                    .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROGRAMS',
                          style: steelHeadingStyle(
                              fontSize: 42, fontWeight: FontWeight.w900)),
                      Container(
                        width: 48,
                        height: 3,
                        margin: const EdgeInsets.only(top: 4, bottom: 6),
                        color: SteelOpsColors.orange,
                      ),
                      Text('${templates.length} LEGEND PROGRAMS',
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
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
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
                            cat,
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
                      ? const Center(
                          child: SteelEmptyState(
                            title: 'No programs here',
                            subtitle: 'Try a different category.',
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

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.template,
    required this.featured,
    required this.onTap,
  });
  final ProgramTemplate template;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                    child: Text('FEATURED',
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
                    '${template.daysPerWeek} DAYS/WEEK  ·  ${template.sessionLength}',
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
                              child: Text(tag,
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
                        featured ? 'VIEW PROGRAM' : 'VIEW',
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
