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
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final String bodyPart;
  final String target;
  final String image;

  factory ExerciseCatalogItem.fromRecord(RecordModel r) => ExerciseCatalogItem(
        id: r.id,
        name: r.get<String>('name', 'Exercise'),
        muscleGroup: r.get<String>('muscleGroup', ''),
        equipment: r.get<String>('equipment', ''),
        instructions: r.get<String>('instructions', ''),
      );

  /// Build from a record in the bundled `assets/exercises.json` catalog
  /// (the same dataset the web app's library uses).
  factory ExerciseCatalogItem.fromJson(Map<String, dynamic> j) {
    final muscle =
        (j['muscleGroup'] ?? j['target'] ?? j['bodyPart'] ?? '').toString();
    return ExerciseCatalogItem(
      id: (j['id'] ?? j['slug'] ?? '').toString(),
      name: (j['name'] ?? 'Exercise').toString(),
      muscleGroup: muscle,
      equipment: (j['equipment'] ?? '').toString(),
      instructions: (j['instructions'] ?? '').toString(),
      bodyPart: (j['bodyPart'] ?? '').toString(),
      target: (j['target'] ?? '').toString(),
      image: (j['image'] ?? j['gif'] ?? '').toString(),
    );
  }
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
  final String sessionLength;
  final List<String> tags;

  /// The raw record — kept so we can instantiate a plan from `structure`.
  final RecordModel raw;

  List<TemplateDay> get trainingDays =>
      days.where((d) => !d.isRest && d.exercises.isNotEmpty).toList();

  int get daysPerWeek => days.where((d) => !d.isRest).length;

  static const _slugMeta = <String, Map<String, dynamic>>{
    'arnold': {
      'athlete': 'Arnold Schwarzenegger',
      'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
      'len': '75-90 min',
      'tags': ['Classic Bodybuilding', 'High Volume', 'Pump Focus'],
    },
    'platz': {
      'athlete': 'Tom Platz',
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'len': '75-105 min',
      'tags': ['Quad Focus', 'High Intensity', 'Extreme Volume'],
    },
    'piana': {
      'athlete': 'Rich Piana',
      'image': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
      'len': '90-120 min',
      'tags': ['Extreme Volume', 'High Intensity', 'Drop Sets'],
    },
    'mentzer': {
      'athlete': 'Mike Mentzer',
      'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
      'len': '30-45 min',
      'tags': ['HIT', 'Low Volume', 'Maximum Intensity'],
    },
    'yates': {
      'athlete': 'Dorian Yates',
      'image': 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800',
      'len': '45-60 min',
      'tags': ['Blood & Guts', 'HIT', 'Controlled Negatives'],
    },
    'ronnie': {
      'athlete': 'Ronnie Coleman',
      'image': 'https://images.unsplash.com/photo-1526232760687-16e82e987c72?w=800',
      'len': '75-90 min',
      'tags': ['High Frequency', 'Heavy Compounds', 'Maximum Mass'],
    },
    'nippard': {
      'athlete': 'Jeff Nippard',
      'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
      'len': '60-75 min',
      'tags': ['Science-Based', 'RIR Tracking', 'Evidence-Based'],
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
