import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:steel/l10n/app_localizations.dart';

import '../../core/router.dart';
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

  // Normalize for locale-independent matching: uppercase, drop non-alphanumeric
  // (so "BODYWEIGHT" matches "body weight", "LEGS" matches "upper legs", etc.).
  static String _norm(String s) =>
      s.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Does any canonical-English taxonomy segment of the item match the selected
  /// facet value? Filtering runs on `filterKey` (always English), NOT on the
  /// translated display fields — so filters work in every language.
  bool _facetMatches(String filterKey, String selected) {
    final needle = _norm(selected);
    if (needle.isEmpty) return true;
    return filterKey.split('|').any((seg) => _norm(seg).contains(needle));
  }

  /// Client-side faceted filter applied on top of the server search result.
  List<ExerciseCatalogItem> _applyClientFilters(
      List<ExerciseCatalogItem> items) {
    return items.where((e) {
      final matchCategory = _selectedCategory == 'ALL' ||
          _facetMatches(e.filterKey, _selectedCategory);
      final matchEquip = _selectedEquipment == 'ANY EQUIP.' ||
          _facetMatches(e.filterKey, _selectedEquipment);
      final matchMuscle = _selectedMuscle == 'ALL MUSCLES' ||
          _facetMatches(e.filterKey, _selectedMuscle);
      return matchCategory && matchEquip && matchMuscle;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(exerciseCatalogProvider);
    final t = ref.watch(tProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top breathing room below the status bar.
            const SizedBox(height: 10),
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
                            t('library.FIELD_MANUAL'),
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
                            catalog.isLoading
                                ? t('library.LOADING')
                                : t('library.LOADED'),
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
                        t('library.ENTRIES'),
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
                        t('library.TITLE'),
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
                        hintText: t('library.SEARCH_HINT'),
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
              t: t,
            ),
            const SizedBox(height: 8),
            _FilterRow(
              items: _equipmentFilters,
              selected: _selectedEquipment,
              onSelect: (v) => setState(() => _selectedEquipment = v),
              t: t,
            ),
            const SizedBox(height: 8),
            _FilterRow(
              items: _muscleFilters,
              selected: _selectedMuscle,
              onSelect: (v) => setState(() => _selectedMuscle = v),
              t: t,
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
                          t('library.LOAD_FAILED'),
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
                              t('common.RETRY'),
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
                        title: t('library.NO_RESULTS'),
                        subtitle: items.isEmpty
                            ? t('library.EMPTY_CATALOG')
                            : t('library.ADJUST_FILTERS'),
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
    required this.t,
  });
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String) t;

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
                t('library.filter.$item'),
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

  void _openDetail(BuildContext context) {
    // Separate detail PAGE (route) — mirrors the web /exercises/[slug].
    context.push(
      SteelRoutes.exerciseDetailPathFor(exercise.id),
      extra: exercise,
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
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: SteelOpsColors.surfaceElevated,
          border: Border.all(color: SteelOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated demo (gif) with spinner + icon fallback.
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: SteelOpsColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _CardMedia(url: exercise.gifUrl, accent: accent),
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

// ── Card media (gif with spinner + icon fallback) ────────────────────────────

class _CardMedia extends StatelessWidget {
  const _CardMedia({required this.url, required this.accent});
  final String url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallbackIcon();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: accent.withAlpha(160),
          ),
        ),
      ),
      errorWidget: (_, _, _) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(
        Icons.fitness_center,
        color: accent.withAlpha(80),
        size: 36,
      ),
    );
  }
}
