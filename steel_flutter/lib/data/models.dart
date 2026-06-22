import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

// ─────────────────────────────────────────────────────────────────────────
// Parsing helpers
// ─────────────────────────────────────────────────────────────────────────

/// Parse a PocketBase JSON field that should be a `List<String>`.
/// Tolerates: real lists, JSON-encoded strings, single strings, or null.
List<String> asStringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {/* fall through */}
    }
    return [trimmed];
  }
  return const [];
}

/// Parse a PocketBase JSON field that should be a `Map<String, dynamic>`.
Map<String, dynamic> asMap(dynamic value) {
  if (value == null) return const {};
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {/* ignore */}
  }
  return const {};
}

double asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int asInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

// ─────────────────────────────────────────────────────────────────────────
// Profile + Goals
// ─────────────────────────────────────────────────────────────────────────

class Profile {
  const Profile({
    required this.id,
    required this.user,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.fitnessLevel,
    required this.goalType,
    required this.environment,
    required this.injuryHistory,
  });

  final String id;
  final String user;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String gender;
  final String fitnessLevel;
  final String goalType;
  final String environment;
  final String injuryHistory;

  factory Profile.fromRecord(RecordModel r) => Profile(
        id: r.id,
        user: r.get<String>('user', ''),
        age: asInt(r.data['age']),
        height: asDouble(r.data['height']),
        weight: asDouble(r.data['weight'] ?? r.data['currentWeight']),
        gender: r.get<String>('gender', ''),
        fitnessLevel: r.get<String>('fitnessLevel', ''),
        goalType: r.get<String>('goalType', ''),
        environment: r.get<String>('environment', ''),
        injuryHistory: r.get<String>('injuryHistory', ''),
      );
}

// ─────────────────────────────────────────────────────────────────────────
// Workout plans
// ─────────────────────────────────────────────────────────────────────────

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.user,
    required this.title,
    required this.description,
    required this.source,
    required this.goalType,
    required this.environment,
    required this.durationWeeks,
    required this.currentWeek,
    required this.status,
    required this.imageUrls,
    required this.created,
  });

  final String id;
  final String user;
  final String title;
  final String description;
  final String source;
  final String goalType;
  final String environment;
  final int durationWeeks;
  final int currentWeek;
  final String status;
  final List<String> imageUrls;
  final String created;

  bool get isActive => status == 'active';

  factory WorkoutPlan.fromRecord(RecordModel r) => WorkoutPlan(
        id: r.id,
        user: r.get<String>('user', ''),
        title: r.get<String>('title', 'Untitled'),
        description: r.get<String>('description', ''),
        source: r.get<String>('source', 'custom'),
        goalType: r.get<String>('goalType', ''),
        environment: r.get<String>('environment', ''),
        durationWeeks: asInt(r.data['durationWeeks']),
        currentWeek: asInt(r.data['currentWeek']) == 0 ? 1 : asInt(r.data['currentWeek']),
        status: r.get<String>('status', 'active'),
        imageUrls: asStringList(r.data['imageUrls']),
        created: r.get<String>('created', ''),
      );
}

class PlanDay {
  const PlanDay({
    required this.id,
    required this.plan,
    required this.week,
    required this.dayOfWeek,
    required this.label,
    required this.focus,
  });

  final String id;
  final String plan;
  final int week;
  final int dayOfWeek;
  final String label;
  final List<String> focus;

  factory PlanDay.fromRecord(RecordModel r) => PlanDay(
        id: r.id,
        plan: r.get<String>('plan', ''),
        week: asInt(r.data['week']),
        dayOfWeek: asInt(r.data['dayOfWeek']),
        label: r.get<String>('label', ''),
        focus: asStringList(r.data['focus']),
      );
}

class PlanExercise {
  const PlanExercise({
    required this.id,
    required this.planDay,
    required this.exercise,
    required this.name,
    required this.order,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.rpeTarget,
    required this.restSeconds,
    required this.notes,
  });

  final String id;
  final String planDay;
  final String exercise;
  final String name;
  final int order;
  final int sets;
  final int repsMin;
  final int repsMax;
  final double rpeTarget;
  final int restSeconds;
  final String notes;

  /// Resolved display name: explicit `name`, else expanded exercise name, else id.
  String get displayName {
    if (name.isNotEmpty) return name;
    return name;
  }

  factory PlanExercise.fromRecord(RecordModel r) {
    final expandedName = r.get<String>('expand.exercise.name', '');
    final rawName = r.get<String>('name', '');
    return PlanExercise(
      id: r.id,
      planDay: r.get<String>('planDay', ''),
      exercise: r.get<String>('exercise', ''),
      name: rawName.isNotEmpty ? rawName : expandedName,
      order: asInt(r.data['order']),
      sets: asInt(r.data['sets']),
      repsMin: asInt(r.data['repsMin']),
      repsMax: asInt(r.data['repsMax']),
      rpeTarget: asDouble(r.data['rpeTarget']),
      restSeconds: asInt(r.data['restSeconds']),
      notes: r.get<String>('notes', ''),
    );
  }

  String get repsLabel => repsMin == repsMax ? '$repsMin' : '$repsMin-$repsMax';
}

// ─────────────────────────────────────────────────────────────────────────
// Exercise catalog
// ─────────────────────────────────────────────────────────────────────────

class ExerciseCatalogItem {
  const ExerciseCatalogItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    this.bodyPart = '',
    this.target = '',
    this.image = '',
    this.gifUrl = '',
    this.slug = '',
    this.secondaryMuscles = const [],
    this.steps = const [],
    this.filterKey = '',
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final String bodyPart;
  final String target;
  final String image;

  /// Canonical ENGLISH taxonomy (bodyPart|target|muscleGroup|equipment|
  /// secondaryMuscles), '|'-joined. Built once from the source and PRESERVED
  /// through [withTranslation], so faceted filtering stays correct in every
  /// language (display fields get translated; this stays English).
  final String filterKey;

  static String buildFilterKey(Iterable<String> parts) =>
      parts.where((p) => p.trim().isNotEmpty).join('|');

  /// Animated demo URL from the ExerciseDB API (empty in offline/bundled mode).
  final String gifUrl;

  /// URL-safe slug derived from the name (mirrors the web's `slugify`).
  final String slug;

  /// Synergist muscles worked alongside the primary target.
  final List<String> secondaryMuscles;

  /// Step-by-step instructions as a list (joined form lives in [instructions]).
  final List<String> steps;

  /// Slugify a name like the web app: lowercase, non-alphanumeric runs → `-`,
  /// trimmed of leading/trailing dashes.
  static String slugify(String input) {
    final lowered = input.toLowerCase();
    final dashed = lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return dashed.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  factory ExerciseCatalogItem.fromRecord(RecordModel r) => ExerciseCatalogItem(
        id: r.id,
        name: r.get<String>('name', 'Exercise'),
        muscleGroup: r.get<String>('muscleGroup', ''),
        equipment: r.get<String>('equipment', ''),
        instructions: r.get<String>('instructions', ''),
      );

  /// Build from a raw ExerciseDB API exercise object (envelope already
  /// unwrapped). Mirrors `toLibraryExercise` in `src/lib/exercise-library.ts`.
  factory ExerciseCatalogItem.fromApi(Map<String, dynamic> j) {
    final steps = asStringList(j['instructions']);
    final bodyPart = asStringList(j['bodyParts']);
    final target = asStringList(j['targetMuscles']);
    final equipment = asStringList(j['equipments']);
    final gif = (j['gifUrl'] ?? j['imageUrl'] ?? '').toString();
    final name = (j['name'] ?? 'Exercise').toString();
    final primaryTarget = target.isNotEmpty ? target.first : '';

    return ExerciseCatalogItem(
      id: (j['exerciseId'] ?? j['id'] ?? '').toString(),
      name: name,
      // Web uses first(targetMuscles) for both muscleGroup and target.
      muscleGroup: primaryTarget,
      target: primaryTarget,
      bodyPart: bodyPart.isNotEmpty ? bodyPart.first : '',
      equipment: equipment.isNotEmpty ? equipment.first : '',
      instructions: steps.join(' '),
      steps: steps,
      secondaryMuscles: asStringList(j['secondaryMuscles']),
      slug: slugify(name),
      gifUrl: gif,
      image: gif,
      filterKey: buildFilterKey([
        bodyPart.isNotEmpty ? bodyPart.first : '',
        primaryTarget,
        equipment.isNotEmpty ? equipment.first : '',
      ]),
    );
  }

  /// Build from a record in the bundled `assets/exercises.json` catalog
  /// (offline fallback — no gif). The bundled shape ships `steps`,
  /// `secondaryMuscles`, `slug`, etc.
  factory ExerciseCatalogItem.fromJson(Map<String, dynamic> j) {
    final muscle =
        (j['muscleGroup'] ?? j['target'] ?? j['bodyPart'] ?? '').toString();
    final name = (j['name'] ?? 'Exercise').toString();
    final image = (j['image'] ?? j['gif'] ?? j['gifUrl'] ?? '').toString();
    final rawSlug = (j['slug'] ?? '').toString();
    return ExerciseCatalogItem(
      id: (j['id'] ?? j['slug'] ?? '').toString(),
      name: name,
      muscleGroup: muscle,
      equipment: (j['equipment'] ?? '').toString(),
      instructions: (j['instructions'] ?? '').toString(),
      bodyPart: (j['bodyPart'] ?? '').toString(),
      target: (j['target'] ?? '').toString(),
      image: image,
      gifUrl: (j['gifUrl'] ?? j['gif'] ?? '').toString(),
      slug: rawSlug.isNotEmpty ? rawSlug : slugify(name),
      secondaryMuscles: asStringList(j['secondaryMuscles']),
      steps: asStringList(j['steps']),
      filterKey: buildFilterKey([
        (j['bodyPart'] ?? '').toString(),
        (j['target'] ?? '').toString(),
        muscle,
        (j['equipment'] ?? '').toString(),
      ]),
    );
  }

  /// Overlay a PocketBase [ExerciseTranslation] on top of this canonical
  /// English exercise. Each field falls back to the English value when the
  /// translation is missing it. Mirrors `applyTranslationToLibraryExercise`
  /// in `src/lib/exercise-translate.ts`.
  ExerciseCatalogItem withTranslation(ExerciseTranslation? t) {
    if (t == null) return this;
    final tSteps = t.steps ?? steps;
    return ExerciseCatalogItem(
      id: id,
      name: t.name ?? name,
      muscleGroup: t.muscleGroup ?? muscleGroup,
      equipment: t.equipment ?? equipment,
      instructions: t.steps != null ? tSteps.join(' ') : instructions,
      bodyPart: t.bodyPart ?? bodyPart,
      target: t.target ?? target,
      image: image,
      gifUrl: gifUrl,
      slug: slug,
      secondaryMuscles: t.secondaryMuscles ?? secondaryMuscles,
      steps: tSteps,
      filterKey: filterKey, // canonical English — never translated
    );
  }
}

/// A translated exercise row from the PocketBase `exercise_translations`
/// collection, keyed by (`exerciseExtId`, `locale`). List fields are stored as
/// newline-joined text in PB and split back on read. Mirrors the web
/// `ExerciseTranslation` shape in `src/lib/exercise-translate.ts`.
class ExerciseTranslation {
  const ExerciseTranslation({
    required this.exerciseExtId,
    this.name,
    this.overview,
    this.steps,
    this.secondaryMuscles,
    this.bodyPart,
    this.equipment,
    this.muscleGroup,
    this.target,
  });

  final String exerciseExtId;
  final String? name;
  final String? overview;
  final List<String>? steps;
  final List<String>? secondaryMuscles;
  final String? bodyPart;
  final String? equipment;
  final String? muscleGroup;
  final String? target;

  factory ExerciseTranslation.fromRecord(RecordModel r) {
    String? str(String key) {
      final v = r.get<String>(key, '').trim();
      return v.isEmpty ? null : v;
    }

    return ExerciseTranslation(
      exerciseExtId: r.get<String>('exerciseExtId', ''),
      name: str('name'),
      overview: str('overview'),
      steps: splitLines(r.get<String>('instructions', '')),
      secondaryMuscles: splitLines(r.get<String>('secondaryMuscles', '')),
      bodyPart: str('bodyPart'),
      equipment: str('equipment'),
      muscleGroup: str('muscleGroup'),
      target: str('target'),
    );
  }

  /// Build from the bundled `assets/exercise-translations.json` entry (same
  /// field names + newline-joined arrays as the PB record). Used for the
  /// offline, auth-free translation overlay.
  factory ExerciseTranslation.fromJson(Map<String, dynamic> j) {
    String? str(String key) {
      final v = (j[key] as String?)?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    return ExerciseTranslation(
      exerciseExtId: (j['exerciseExtId'] as String?) ?? '',
      name: str('name'),
      overview: str('overview'),
      steps: splitLines(j['instructions'] as String?),
      secondaryMuscles: splitLines(j['secondaryMuscles'] as String?),
      bodyPart: str('bodyPart'),
      equipment: str('equipment'),
      muscleGroup: str('muscleGroup'),
      target: str('target'),
    );
  }
}

/// Split a newline-joined PB text field back into a trimmed, non-empty list,
/// or null when there is nothing to split.
List<String>? splitLines(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value
      .split(RegExp(r'\r?\n'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return parts.isEmpty ? null : parts;
}

// ─────────────────────────────────────────────────────────────────────────
// Sessions + sets
// ─────────────────────────────────────────────────────────────────────────

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.user,
    required this.plan,
    required this.planDay,
    required this.startedAt,
    required this.completedAt,
    required this.status,
    required this.mood,
    required this.energyLevel,
    required this.sessionNotes,
    required this.created,
  });

  final String id;
  final String user;
  final String plan;
  final String planDay;
  final String startedAt;
  final String completedAt;
  final String status;
  final String mood;
  final int energyLevel;
  final String sessionNotes;
  final String created;

  bool get isCompleted => status == 'completed';

  DateTime get effectiveDate {
    final raw = completedAt.isNotEmpty
        ? completedAt
        : (startedAt.isNotEmpty ? startedAt : created);
    return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
  }

  factory WorkoutSession.fromRecord(RecordModel r) => WorkoutSession(
        id: r.id,
        user: r.get<String>('user', ''),
        plan: r.get<String>('plan', ''),
        planDay: r.get<String>('planDay', ''),
        startedAt: r.get<String>('startedAt', ''),
        completedAt: r.get<String>('completedAt', ''),
        status: r.get<String>('status', ''),
        mood: r.get<String>('mood', ''),
        energyLevel: asInt(r.data['energyLevel']),
        sessionNotes: r.get<String>('sessionNotes', ''),
        created: r.get<String>('created', ''),
      );
}

class SessionSet {
  const SessionSet({
    required this.id,
    required this.session,
    required this.exercise,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.rpe,
    required this.notes,
    required this.created,
  });

  final String id;
  final String session;
  final String exercise;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weight;
  final double rpe;
  final String notes;
  final String created;

  double get volume => weight * reps;

  factory SessionSet.fromRecord(RecordModel r) {
    final expanded = r.get<String>('expand.exercise.name', '');
    return SessionSet(
      id: r.id,
      session: r.get<String>('session', ''),
      exercise: r.get<String>('exercise', ''),
      exerciseName: expanded,
      setNumber: asInt(r.data['setNumber']),
      reps: asInt(r.data['reps']),
      weight: asDouble(r.data['weight']),
      rpe: asDouble(r.data['rpe']),
      notes: r.get<String>('notes', ''),
      created: r.get<String>('created', ''),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Goals
// ─────────────────────────────────────────────────────────────────────────

class Goal {
  const Goal({
    required this.id,
    required this.user,
    required this.goalType,
    required this.targetWeight,
    required this.deadline,
    required this.notes,
  });

  final String id;
  final String user;
  final String goalType;
  final double targetWeight;
  final String deadline;
  final String notes;

  factory Goal.fromRecord(RecordModel r) => Goal(
        id: r.id,
        user: r.get<String>('user', ''),
        goalType: r.get<String>('goalType', ''),
        targetWeight: asDouble(r.data['targetWeight']),
        deadline: r.get<String>('deadline', ''),
        notes: r.get<String>('notes', ''),
      );
}

// ─────────────────────────────────────────────────────────────────────────
// Program templates (plan_templates) — embedded multilingual structure
// ─────────────────────────────────────────────────────────────────────────

class TemplateExercise {
  const TemplateExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.tempo,
    required this.notes,
  });
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String tempo;
  final String notes;
}

class TemplateDay {
  const TemplateDay({
    required this.dayNumber,
    required this.label,
    required this.isRest,
    required this.exercises,
  });
  final int dayNumber;
  final String label;
  final bool isRest;
  final List<TemplateExercise> exercises;
}

/// A program template projected onto a single active locale.
class ProgramTemplate {
  const ProgramTemplate({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.goalType,
    required this.difficulty,
    required this.durationWeeks,
    required this.popularity,
    required this.split,
    required this.bestFor,
    required this.characteristics,
    required this.days,
    required this.progression,
    required this.recovery,
    required this.athleteName,
    required this.image,
    required this.images,
    required this.sessionLength,
    required this.tags,
    required this.raw,
  });

  final String id;
  final String slug;
  final String title;
  final String description;
  final String goalType;
  final String difficulty;
  final int durationWeeks;
  final int popularity;
  final String split;
  final String bestFor;
  final List<String> characteristics;
  final List<TemplateDay> days;
  final List<String> progression;
  final List<String> recovery;
  final String athleteName;
  final String image;
  /// Carousel images for the detail screen (prev first, then the rest).
  final List<String> images;
  final String sessionLength;
  final List<String> tags;

  /// The raw record — kept so we can instantiate a plan from `structure`.
  final RecordModel raw;

  List<TemplateDay> get trainingDays =>
      days.where((d) => !d.isRest && d.exercises.isNotEmpty).toList();

  int get daysPerWeek => days.where((d) => !d.isRest).length;

  // NOTE: `tags` hold canonical, language-independent keys. The UI resolves them
  // through `t('programs.tag.<KEY>')` so they localize with the active language.
  static const _slugMeta = <String, Map<String, dynamic>>{
    // image = card preview (prev.jpg); carousel = detail images (prev first).
    'arnold': {
      'athlete': 'Arnold Schwarzenegger',
      'image': 'https://steel.xodjayev.uz/legends/arnold/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/arnold/prev.jpg',
        'https://steel.xodjayev.uz/legends/arnold/1.jpg',
        'https://steel.xodjayev.uz/legends/arnold/2.jpg',
      ],
      'len': '75-90 min',
      'tags': ['CLASSIC_BB', 'HIGH_VOLUME', 'PUMP_FOCUS'],
    },
    'platz': {
      'athlete': 'Tom Platz',
      'image': 'https://steel.xodjayev.uz/legends/platz/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/platz/prev.jpg',
        'https://steel.xodjayev.uz/legends/platz/1.jpg',
        'https://steel.xodjayev.uz/legends/platz/2.webp',
      ],
      'len': '75-105 min',
      'tags': ['QUAD_FOCUS', 'HIGH_INTENSITY', 'EXTREME_VOLUME'],
    },
    'piana': {
      'athlete': 'Rich Piana',
      'image': 'https://steel.xodjayev.uz/legends/piana/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/piana/prev.jpg',
        'https://steel.xodjayev.uz/legends/piana/1.jpg',
      ],
      'len': '90-120 min',
      'tags': ['EXTREME_VOLUME', 'HIGH_INTENSITY', 'DROP_SETS'],
    },
    'mentzer': {
      'athlete': 'Mike Mentzer',
      'image': 'https://steel.xodjayev.uz/legends/mentzer/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/mentzer/prev.jpg',
        'https://steel.xodjayev.uz/legends/mentzer/1.png',
        'https://steel.xodjayev.uz/legends/mentzer/2.jpg',
        'https://steel.xodjayev.uz/legends/mentzer/3.jpg',
      ],
      'len': '30-45 min',
      'tags': ['HIT', 'LOW_VOLUME', 'MAX_INTENSITY'],
    },
    'yates': {
      'athlete': 'Dorian Yates',
      'image': 'https://steel.xodjayev.uz/legends/yates/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/yates/prev.jpg',
        'https://steel.xodjayev.uz/legends/yates/1.jpg',
        'https://steel.xodjayev.uz/legends/yates/2.jpg',
      ],
      'len': '45-60 min',
      'tags': ['BLOOD_GUTS', 'HIT', 'CONTROLLED_NEG'],
    },
    'ronnie': {
      'athlete': 'Ronnie Coleman',
      'image': 'https://steel.xodjayev.uz/legends/ronnie/prev.jpg',
      'carousel': [
        'https://steel.xodjayev.uz/legends/ronnie/prev.jpg',
        'https://steel.xodjayev.uz/legends/ronnie/1.webp',
        'https://steel.xodjayev.uz/legends/ronnie/2.jpg',
      ],
      'len': '75-90 min',
      'tags': ['HIGH_FREQUENCY', 'HEAVY_COMPOUNDS', 'MAX_MASS'],
    },
    'nippard': {
      'athlete': 'Jeff Nippard',
      'image': 'https://steel.xodjayev.uz/legends/nippard/prev.jpg',
      'carousel': ['https://steel.xodjayev.uz/legends/nippard/prev.jpg'],
      'len': '60-75 min',
      'tags': ['SCIENCE_BASED', 'RIR_TRACKING', 'EVIDENCE_BASED'],
    },
  };

  /// Build from a `plan_templates` record, projecting `structure.locales[lang]`.
  factory ProgramTemplate.fromRecord(RecordModel r, String lang) {
    final structure = asMap(r.data['structure']);
    final slug = (structure['slug'] ?? 'unknown').toString();
    final locales = asMap(structure['locales']);
    final locale = asMap(locales[lang] ?? locales['en'] ?? {});

    final overview = asMap(locale['overview']);
    final guidelines = asMap(locale['guidelines']);
    final rawDays = (locale['days'] is List) ? locale['days'] as List : const [];

    final days = rawDays.map<TemplateDay>((d) {
      final dm = asMap(d);
      final exList = (dm['exercises'] is List) ? dm['exercises'] as List : const [];
      return TemplateDay(
        dayNumber: asInt(dm['dayNumber']),
        label: (dm['label'] ?? '').toString(),
        isRest: dm['isRest'] == true,
        exercises: exList.map<TemplateExercise>((e) {
          final em = asMap(e);
          final restSec = asInt(em['restSeconds']);
          return TemplateExercise(
            name: (em['name'] ?? '').toString(),
            sets: (em['sets'] ?? '').toString(),
            reps: (em['repsRange'] ?? em['reps'] ?? '').toString(),
            rest: restSec >= 120
                ? '${(restSec / 60).round()} min'
                : (restSec > 0 ? '${restSec}s' : ''),
            tempo: (em['tempo'] ?? '').toString(),
            notes: (em['notes'] ?? '').toString(),
          );
        }).toList(),
      );
    }).toList();

    final meta = _slugMeta[slug];

    return ProgramTemplate(
      id: r.id,
      slug: slug,
      title: (locale['title'] ?? r.get<String>('title', 'Program')).toString(),
      description: (locale['description'] ?? r.get<String>('description', '')).toString(),
      goalType: r.get<String>('goalType', ''),
      difficulty: r.get<String>('difficulty', ''),
      durationWeeks: asInt(r.data['durationWeeks']),
      popularity: asInt(r.data['popularity']),
      split: (overview['split'] ?? '').toString(),
      bestFor: (overview['bestFor'] ?? '').toString(),
      characteristics: asStringList(overview['characteristics']),
      days: days,
      progression: asStringList(guidelines['progression']),
      recovery: asStringList(guidelines['recovery']),
      athleteName: (meta?['athlete'] ?? r.get<String>('title', '')).toString(),
      image: (meta?['image'] ?? '').toString(),
      images: meta?['carousel'] != null
          ? List<String>.from(meta!['carousel'] as List)
          : <String>[(meta?['image'] ?? '').toString()].where((s) => s.isNotEmpty).toList(),
      sessionLength: (meta?['len'] ?? '60-90 min').toString(),
      tags: meta != null ? List<String>.from(meta['tags'] as List) : const [],
      raw: r,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Progress aggregates (mirrors web useProgress)
// ─────────────────────────────────────────────────────────────────────────

class ProgressData {
  const ProgressData({required this.sessions, required this.sets});
  final List<WorkoutSession> sessions; // completed only
  final List<SessionSet> sets;

  static const empty = ProgressData(sessions: [], sets: []);
}

class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.thisWeekSessions,
    required this.thisMonthSessions,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int thisWeekSessions;
  final int thisMonthSessions;

  static const zero = StreakData(
    currentStreak: 0,
    longestStreak: 0,
    totalSessions: 0,
    thisWeekSessions: 0,
    thisMonthSessions: 0,
  );
}

class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.estimated1RM,
    required this.date,
  });
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final double estimated1RM;
  final String date;
}

class MuscleSlice {
  const MuscleSlice({required this.name, required this.volume, required this.count});
  final String name;
  final double volume;
  final int count;
}
