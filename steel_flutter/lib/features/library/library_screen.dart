import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';

// ── Filter constants ─────────────────────────────────────────────────────────

const _muscleCategories = [
  'ALL',
  'BACK',
  'CHEST',
  'LEGS',
  'SHOULDERS',
  'BICEPS',
  'TRICEPS',
  'ABS',
  'GLUTES',
  'CARDIO',
];

const _equipmentFilters = [
  'ANY EQUIP.',
  'ASSISTED',
  'BAND',
  'BARBELL',
  'BODYWEIGHT',
  'DUMBBELL',
  'MACHINE',
  'KETTLEBELL',
];

const _muscleFilters = [
  'ALL MUSCLES',
  'ABDUCTORS',
  'ABS',
  'ADDUCTORS',
  'BICEPS',
  'CHEST',
  'GLUTES',
  'HAMSTRINGS',
  'QUADRICEPS',
  'SHOULDERS',
  'TRICEPS',
];

// ── Screen ───────────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _selectedCategory = 'ALL';
  String _selectedEquipment = 'ANY EQUIP.';
  String _selectedMuscle = 'ALL MUSCLES';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(exerciseSearchProvider.notifier).state = value.trim();
    });
  }

  /// Client-side filter applied on top of the server search result.
  List<ExerciseCatalogItem> _applyClientFilters(
      List<ExerciseCatalogItem> items) {
    return items.where((e) {
      final muscle = e.muscleGroup.toUpperCase();
      final equip = e.equipment.toUpperCase();

      final matchCategory =
          _selectedCategory == 'ALL' || muscle.contains(_selectedCategory);
      final matchEquip = _selectedEquipment == 'ANY EQUIP.' ||
          equip.contains(_selectedEquipment.toUpperCase());
      final matchMuscle = _selectedMuscle == 'ALL MUSCLES' ||
          muscle.contains(_selectedMuscle.toUpperCase());
      return matchCategory && matchEquip && matchMuscle;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(exerciseCatalogProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top label row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'FIELD MANUAL',
                            style: steelMonoStyle(
                              fontSize: 10,
                              color: SteelOpsColors.muted,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: SteelOpsColors.borderStrong,
                          ),
                          Text(
                            catalog.isLoading ? 'LOADING' : 'LOADED',
                            style: steelMonoStyle(
                              fontSize: 10,
                              color: catalog.isLoading
                                  ? SteelOpsColors.muted
                                  : SteelOpsColors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'ENTRIES',
                        style: steelMonoStyle(
                          fontSize: 10,
                          color: SteelOpsColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title + count row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXERCISE LIBRARY',
                        style: steelHeadingStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      catalog.when(
                        data: (items) {
                          final filtered = _applyClientFilters(items);
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${filtered.length} ',
                                  style: steelHeadingStyle(
                                    fontSize: 28,
                                    color: SteelOpsColors.heroText,
                                  ),
                                ),
                                TextSpan(
                                  text: '/ ${items.length}',
                                  style: steelHeadingStyle(
                                    fontSize: 28,
                                    color: SteelOpsColors.orange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => Text(
                          '—',
                          style: steelHeadingStyle(
                            fontSize: 28,
                            color: SteelOpsColors.inkDim,
                          ),
                        ),
                        error: (_, _) => Text(
                          'ERR',
                          style: steelHeadingStyle(
                            fontSize: 28,
                            color: SteelOpsColors.rust,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 3,
                    margin: const EdgeInsets.only(top: 4, bottom: 16),
                    color: SteelOpsColors.orange,
                  ),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: SteelOpsColors.surfaceElevated,
                      border: Border.all(
                        color: SteelOpsColors.orange,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: steelMonoStyle(
                        fontSize: 12,
                        color: SteelOpsColors.inkHigh,
                      ),
                      decoration: InputDecoration(
                        hintText: 'SEARCH EXERCISES...',
                        hintStyle: steelMonoStyle(
                          fontSize: 12,
                          color: SteelOpsColors.muted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: SteelOpsColors.orange,
                          size: 20,
                        ),
                        suffixIcon: catalog.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: SteelOpsColors.orange,
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Filter rows ───────────────────────────────────────────────
            _FilterRow(
              items: _muscleCategories,
              selected: _selectedCategory,
              onSelect: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 8),
            _FilterRow(
              items: _equipmentFilters,
              selected: _selectedEquipment,
              onSelect: (v) => setState(() => _selectedEquipment = v),
            ),
            const SizedBox(height: 8),
            _FilterRow(
              items: _muscleFilters,
              selected: _selectedMuscle,
              onSelect: (v) => setState(() => _selectedMuscle = v),
            ),
            const SizedBox(height: 12),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: catalog.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: SteelOpsColors.orange,
                    strokeWidth: 2,
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: SteelOpsColors.rust,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FAILED TO LOAD EXERCISES',
                          style: steelHeadingStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SteelOpsColors.rust,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: steelMonoStyle(
                            fontSize: 10,
                            color: SteelOpsColors.muted,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              ref.invalidate(exerciseCatalogProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: SteelOpsColors.orange, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RETRY',
                              style: steelMonoStyle(
                                fontSize: 11,
                                color: SteelOpsColors.orange,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (items) {
                  final filtered = _applyClientFilters(items);
                  if (filtered.isEmpty) {
                    return Center(
                      child: SteelEmptyState(
                        icon: Icons.search_off_outlined,
                        title: 'No exercises found',
                        subtitle: items.isEmpty
                            ? 'Exercise catalog is empty'
                            : 'Try adjusting your filters or search term',
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _ExerciseCard(exercise: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Horizontal filter row ────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.items,
    required this.selected,
    required this.onSelect,
  });
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = selected == item;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? SteelOpsColors.orange : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? SteelOpsColors.orange
                        : SteelOpsColors.borderStrong,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                item,
                style: steelMonoStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : SteelOpsColors.inkMid,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Exercise card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});
  final ExerciseCatalogItem exercise;

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExerciseDetailSheet(exercise: exercise),
    );
  }

  // Map a muscle group string to a label color accent.
  Color _accentColor() {
    final mg = exercise.muscleGroup.toUpperCase();
    if (mg.contains('CHEST')) return SteelOpsColors.rust;
    if (mg.contains('BACK')) return SteelOpsColors.forge;
    if (mg.contains('LEG') ||
        mg.contains('QUAD') ||
        mg.contains('HAMSTRING') ||
        mg.contains('GLUTE')) {
      return SteelOpsColors.tactical;
    }
    if (mg.contains('SHOULDER')) return SteelOpsColors.blue;
    return SteelOpsColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: SteelOpsColors.surfaceElevated,
          border: Border.all(color: SteelOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: SteelOpsColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: accent.withAlpha(80),
                    size: 36,
                  ),
                ),
              ),
            ),

            // Accent line
            Container(height: 2, color: accent),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: steelHeadingStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscleGroup.toUpperCase(),
                    style: steelMonoStyle(
                      fontSize: 9,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.equipment.toUpperCase(),
                    style: steelMonoStyle(
                      fontSize: 9,
                      color: SteelOpsColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise detail sheet ────────────────────────────────────────────────────

class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({required this.exercise});
  final ExerciseCatalogItem exercise;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SteelOpsColors.surface,
            border: Border(
              top: BorderSide(color: SteelOpsColors.orange, width: 2),
              left: BorderSide(color: SteelOpsColors.border),
              right: BorderSide(color: SteelOpsColors.border),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: SteelOpsColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Mono label
              Text(
                'EXERCISE DETAIL',
                style: steelMonoStyle(
                  fontSize: 10,
                  color: SteelOpsColors.orange,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                exercise.name,
                style: steelHeadingStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(top: 4, bottom: 16),
                color: SteelOpsColors.orange,
              ),

              // Tags row
              Row(
                children: [
                  _Tag(
                    label: exercise.muscleGroup.toUpperCase(),
                    color: SteelOpsColors.orange,
                  ),
                  const SizedBox(width: 8),
                  _Tag(
                    label: exercise.equipment.toUpperCase(),
                    color: SteelOpsColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Instructions
              Text(
                'INSTRUCTIONS',
                style: steelMonoStyle(
                  fontSize: 10,
                  color: SteelOpsColors.muted,
                  letterSpacing: 2,
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: SteelOpsColors.border,
              ),
              exercise.instructions.trim().isEmpty
                  ? Text(
                      'No instructions available.',
                      style: steelMonoStyle(
                        fontSize: 12,
                        color: SteelOpsColors.inkDim,
                        letterSpacing: 0.5,
                      ),
                    )
                  : Text(
                      exercise.instructions,
                      style: steelMonoStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: SteelOpsColors.inkMid,
                        letterSpacing: 0.5,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(120)),
        borderRadius: BorderRadius.circular(2),
        color: color.withAlpha(20),
      ),
      child: Text(
        label,
        style: steelMonoStyle(fontSize: 10, color: color, letterSpacing: 1),
      ),
    );
  }
}
