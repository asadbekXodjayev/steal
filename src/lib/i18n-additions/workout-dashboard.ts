import type { Language, TranslationData } from "@/lib/translations";

/**
 * Localization additions for the Workout + Dashboard area
 * (src/app/(app)/workout/**, src/app/(app)/dashboard/**,
 *  src/components/workout/**).
 * Deep-merged into the base translations. Every key MUST exist in en, ru and uz.
 */
const additions: Partial<Record<Language, TranslationData>> = {
  en: {
    workout: {
      // ExerciseCard column headers
      SET_HEADER: "SET",
      WEIGHT_HEADER: "WEIGHT",
      REPS_HEADER: "REPS",
      // ExerciseCard action buttons
      ADD_SET: "+ Add Set",
      LOG_SET: "Log Set ✓",
      ACTIVE_TAG: "ACTIVE",
      // ExerciseCard gif placeholder
      EXERCISE_GIF_PLACEHOLDER: "EXERCISE GIF",
      // SetRow aria-labels (use {n} for set number)
      SET_WEIGHT_LABEL: "Set {n} weight",
      SET_REPS_LABEL: "Set {n} reps",
      LOG_SET_LABEL: "Log set {n}",
      // RestTimer
      SKIP_REST: "Skip rest",
      REST_COMPLETE: "Rest complete — you're ready for the next set",
      // Session page inline labels
      REST_LABEL: "REST",
      WORKOUT_FALLBACK: "WORKOUT",
      EXERCISE_FALLBACK: "Exercise {n}",
      PLAN_COMPLETED: "Program complete!",
      // Dashboard
      WEEK_LABEL: "Week {n}",
    },
    // ExerciseMedia
    exerciseMedia: {
      NO_TUTORIAL: "No tutorial",
      TUTORIAL_LABEL: "Tutorial",
      VIEW_FULL_TUTORIAL: "View full tutorial",
      VIEW_TUTORIAL_FOR: "View tutorial for {name}",
      VIEW_FULL_TUTORIAL_FOR: "View full tutorial for {name}",
    },
    // MoodCheck labels (full descriptions used as aria-labels)
    mood: {
      GREAT_LABEL: "Feeling great",
      GOOD_LABEL: "Good energy",
      OKAY_LABEL: "Okay",
      ROUGH_LABEL: "Rough day",
      TERRIBLE_LABEL: "Really struggling",
    },
    dashboard: {
      WEEK_LABEL: "Week {n}",
    },
  },
  ru: {
    workout: {
      SET_HEADER: "ПОДХОД",
      WEIGHT_HEADER: "ВЕС",
      REPS_HEADER: "ПОВТ.",
      ADD_SET: "+ Добавить подход",
      LOG_SET: "Записать ✓",
      ACTIVE_TAG: "АКТИВНО",
      EXERCISE_GIF_PLACEHOLDER: "АНИМАЦИЯ",
      SET_WEIGHT_LABEL: "Подход {n} — вес",
      SET_REPS_LABEL: "Подход {n} — повторения",
      LOG_SET_LABEL: "Записать подход {n}",
      SKIP_REST: "Пропустить отдых",
      REST_COMPLETE: "Отдых завершён — готов к следующему подходу",
      REST_LABEL: "ОТДЫХ",
      WORKOUT_FALLBACK: "ТРЕНИРОВКА",
      EXERCISE_FALLBACK: "Упражнение {n}",
      PLAN_COMPLETED: "Программа завершена!",
      WEEK_LABEL: "Неделя {n}",
    },
    exerciseMedia: {
      NO_TUTORIAL: "Нет обучения",
      TUTORIAL_LABEL: "Обучение",
      VIEW_FULL_TUTORIAL: "Полное обучение",
      VIEW_TUTORIAL_FOR: "Смотреть обучение: {name}",
      VIEW_FULL_TUTORIAL_FOR: "Полное обучение: {name}",
    },
    mood: {
      GREAT_LABEL: "Отлично",
      GOOD_LABEL: "Хорошая энергия",
      OKAY_LABEL: "Нормально",
      ROUGH_LABEL: "Тяжёлый день",
      TERRIBLE_LABEL: "Очень тяжело",
    },
    dashboard: {
      WEEK_LABEL: "Неделя {n}",
    },
  },
  uz: {
    workout: {
      SET_HEADER: "YONDASHUV",
      WEIGHT_HEADER: "OG'IRLIK",
      REPS_HEADER: "TAKR.",
      ADD_SET: "+ Yondashuv qo'shish",
      LOG_SET: "Yozish ✓",
      ACTIVE_TAG: "FAOL",
      EXERCISE_GIF_PLACEHOLDER: "ANIMATSIYA",
      SET_WEIGHT_LABEL: "{n}-yondashuv — og'irlik",
      SET_REPS_LABEL: "{n}-yondashuv — takrorlar",
      LOG_SET_LABEL: "{n}-yondashuvni yozish",
      SKIP_REST: "Dam olishni o'tkazib yuborish",
      REST_COMPLETE: "Dam olish tugadi — keyingi yondashuvga tayor",
      REST_LABEL: "DAM OLISH",
      WORKOUT_FALLBACK: "MASHQ",
      EXERCISE_FALLBACK: "Mashq {n}",
      PLAN_COMPLETED: "Dastur yakunlandi!",
      WEEK_LABEL: "{n}-hafta",
    },
    exerciseMedia: {
      NO_TUTORIAL: "Qo'llanma yo'q",
      TUTORIAL_LABEL: "Qo'llanma",
      VIEW_FULL_TUTORIAL: "To'liq qo'llanma",
      VIEW_TUTORIAL_FOR: "Qo'llanmani ko'rish: {name}",
      VIEW_FULL_TUTORIAL_FOR: "To'liq qo'llanma: {name}",
    },
    mood: {
      GREAT_LABEL: "A'lo",
      GOOD_LABEL: "Yaxshi energiya",
      OKAY_LABEL: "Normal",
      ROUGH_LABEL: "Og'ir kun",
      TERRIBLE_LABEL: "Juda og'ir",
    },
    dashboard: {
      WEEK_LABEL: "{n}-hafta",
    },
  },
};

export default additions;
