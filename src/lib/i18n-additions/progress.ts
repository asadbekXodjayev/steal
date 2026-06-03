import type { Language, TranslationData } from "@/lib/translations";

/**
 * Localization additions for the Progress area
 * (src/app/(app)/progress/** and src/components/progress/**).
 * Deep-merged into the base translations — keys here extend, never replace,
 * existing namespaces. Every key MUST exist in en, ru and uz.
 */
const additions: Partial<Record<Language, TranslationData>> = {
  en: {
    progress: {
      // ── page.tsx ──
      ALL_TIME_BESTS: "ALL-TIME BESTS",
      RECENT_RECORDS: "RECENT RECORDS",
      E1RM_VS_RPE: "e1RM vs RPE",
      YEAR_LABEL: "YEAR",

      // ── PRBoard ──
      COL_EXERCISE: "EXERCISE",
      COL_WEIGHT: "WEIGHT",
      COL_REPS: "REPS",
      NO_RECORDS_YET: "No records yet — earn them.",
      PR_BOARD_ARIA: "Personal records board",

      // ── PRWall ──
      PERSONAL_RECORDS_LABEL: "PERSONAL RECORDS",
      NO_PRS_FORGE: "No PRs yet — keep forging steel",
      PERSONAL_RECORD_CARD: "PERSONAL RECORD",
      REPS_LABEL: "reps",
      PERSONAL_BEST: "PERSONAL BEST",

      // ── AchievementsBoard ──
      LOCKED: "— LOCKED —",

      // ── CalendarHeatmap ──
      HEATMAP_ARIA: "Training frequency heatmap",
      HEATMAP_SESSION: "session",
      HEATMAP_SESSIONS: "sessions",
      HEATMAP_LESS: "LESS",
      HEATMAP_MORE: "MORE",

      // ── MuscleRadar ──
      MUSCLE_DISTRIBUTION_LABEL: "MUSCLE DISTRIBUTION — VOLUME %",
      MUSCLE_RADAR_BADGE: "MUSCLE RADAR",
      OF_VOLUME: "% of volume",
      HIGHEST: "(highest)",

      // ── EnhancedVolumeChart ──
      INSUFFICIENT_DATA: "Insufficient Data — Log More Sessions",
      PEAK: "Peak",
      AVG: "Avg",
      SESSIONS_LABEL: "Sessions",
      TOOLTIP_VOLUME: "Volume",
      TOOLTIP_AVG_RPE: "Avg RPE",
      TOOLTIP_SESSIONS: "Sessions",

      // ── ProgressTrendChart ──
      LEGEND_MAX_E1RM: "Max e1RM (kg)",
      LEGEND_AVG_RPE: "Avg RPE",
      TOOLTIP_MAX_E1RM: "Max e1RM",
      TOOLTIP_TOTAL_SETS: "Total Sets",

      // ── RepsDistributionChart ──
      NO_REP_DATA: "No Rep Data — Log More Sets",
      TOOLTIP_REPS_SUFFIX: "reps",
      TOOLTIP_OCCURRENCES: "Occurrences",

      // ── MuscleBalance ──
      NO_SPLIT_DATA: "NO SPLIT DATA YET",
      PUSH_LABEL: "PUSH",
      PULL_LABEL: "PULL",
      LEGS_LABEL: "LEGS",

      // ── DonutBreakdown ──
      SPLIT_LABEL: "SPLIT",

      // ── VolumeStackedChart tooltip ──
      TOTAL_LABEL: "TOTAL",

      // ── MusclePieChart ──
      NO_DATA_DISTRIBUTION: "NO DATA",
      LOG_WORKOUTS_DISTRIBUTION: "LOG WORKOUTS TO SEE DISTRIBUTION",
      TOTAL_CENTER: "TOTAL",

      // ── StreakTracker (component-level, not used on /progress page) ──
      STREAK_DAY_STREAK: "Day Streak",
      STREAK_BEST_STREAK: "Best Streak",
      STREAK_THIS_WEEK: "This Week",
      STREAK_TOTAL_SESSIONS: "Total Sessions",

      // ── MuscleDistribution (component-level) ──
      LOG_FOR_DISTRIBUTION: "Log sessions to see muscle distribution.",
      SESSIONS_TOOLTIP: "sessions",

      // ── LiftProgressionChart (component-level) ──
      LOG_FOR_PROGRESSION: "Log sessions to track lift progression.",

      // ── VolumeChart (component-level) ──
      NO_DATA_VOLUME: "No data yet. Log sessions to see volume.",
      VOLUME_TOOLTIP: "Volume",
    },
    muscles: {
      ARMS: "Arms",
    },
  },
  ru: {
    progress: {
      // ── page.tsx ──
      ALL_TIME_BESTS: "ЛУЧШИЕ ЗА ВСЁ ВРЕМЯ",
      RECENT_RECORDS: "ПОСЛЕДНИЕ РЕКОРДЫ",
      E1RM_VS_RPE: "e1RM vs RPE",
      YEAR_LABEL: "ГОД",

      // ── PRBoard ──
      COL_EXERCISE: "УПРАЖНЕНИЕ",
      COL_WEIGHT: "ВЕС",
      COL_REPS: "ПОВТОРЕНИЯ",
      NO_RECORDS_YET: "Рекордов пока нет — заработай их.",
      PR_BOARD_ARIA: "Таблица личных рекордов",

      // ── PRWall ──
      PERSONAL_RECORDS_LABEL: "ЛИЧНЫЕ РЕКОРДЫ",
      NO_PRS_FORGE: "Рекордов пока нет — продолжай ковать сталь",
      PERSONAL_RECORD_CARD: "ЛИЧНЫЙ РЕКОРД",
      REPS_LABEL: "повт.",
      PERSONAL_BEST: "ЛИЧНЫЙ РЕКОРД",

      // ── AchievementsBoard ──
      LOCKED: "— ЗАБЛОКИРОВАНО —",

      // ── CalendarHeatmap ──
      HEATMAP_ARIA: "Тепловая карта частоты тренировок",
      HEATMAP_SESSION: "тренировка",
      HEATMAP_SESSIONS: "тренировок",
      HEATMAP_LESS: "МЕНЬШЕ",
      HEATMAP_MORE: "БОЛЬШЕ",

      // ── MuscleRadar ──
      MUSCLE_DISTRIBUTION_LABEL: "РАСПРЕДЕЛЕНИЕ МЫШЦ — ОБЪЁМ %",
      MUSCLE_RADAR_BADGE: "РАДАР МЫШЦ",
      OF_VOLUME: "% объёма",
      HIGHEST: "(лидер)",

      // ── EnhancedVolumeChart ──
      INSUFFICIENT_DATA: "Недостаточно данных — запишите больше тренировок",
      PEAK: "Пик",
      AVG: "Среднее",
      SESSIONS_LABEL: "Тренировок",
      TOOLTIP_VOLUME: "Объём",
      TOOLTIP_AVG_RPE: "Ср. RPE",
      TOOLTIP_SESSIONS: "Тренировок",

      // ── ProgressTrendChart ──
      LEGEND_MAX_E1RM: "Макс. e1RM (кг)",
      LEGEND_AVG_RPE: "Ср. RPE",
      TOOLTIP_MAX_E1RM: "Макс. e1RM",
      TOOLTIP_TOTAL_SETS: "Всего подходов",

      // ── RepsDistributionChart ──
      NO_REP_DATA: "Нет данных повторений — запишите больше подходов",
      TOOLTIP_REPS_SUFFIX: "повт.",
      TOOLTIP_OCCURRENCES: "Случаев",

      // ── MuscleBalance ──
      NO_SPLIT_DATA: "НЕТ ДАННЫХ СПЛИТА",
      PUSH_LABEL: "ЖИМ",
      PULL_LABEL: "ТЯГА",
      LEGS_LABEL: "НОГИ",

      // ── DonutBreakdown ──
      SPLIT_LABEL: "СПЛИТ",

      // ── VolumeStackedChart tooltip ──
      TOTAL_LABEL: "ИТОГО",

      // ── MusclePieChart ──
      NO_DATA_DISTRIBUTION: "НЕТ ДАННЫХ",
      LOG_WORKOUTS_DISTRIBUTION: "ЗАПИШИТЕ ТРЕНИРОВКИ ДЛЯ СТАТИСТИКИ",
      TOTAL_CENTER: "ИТОГО",

      // ── StreakTracker (component-level) ──
      STREAK_DAY_STREAK: "Серия дней",
      STREAK_BEST_STREAK: "Лучшая серия",
      STREAK_THIS_WEEK: "Эта неделя",
      STREAK_TOTAL_SESSIONS: "Всего тренировок",

      // ── MuscleDistribution (component-level) ──
      LOG_FOR_DISTRIBUTION: "Записывайте тренировки для отображения распределения.",
      SESSIONS_TOOLTIP: "тренировок",

      // ── LiftProgressionChart (component-level) ──
      LOG_FOR_PROGRESSION: "Записывайте тренировки для отслеживания прогрессии.",

      // ── VolumeChart (component-level) ──
      NO_DATA_VOLUME: "Данных пока нет. Запишите тренировки для просмотра объёма.",
      VOLUME_TOOLTIP: "Объём",
    },
    muscles: {
      ARMS: "Руки",
    },
  },
  uz: {
    progress: {
      // ── page.tsx ──
      ALL_TIME_BESTS: "BARCHA VAQT REKORDI",
      RECENT_RECORDS: "SO'NGI REKORDLAR",
      E1RM_VS_RPE: "e1RM vs RPE",
      YEAR_LABEL: "YIL",

      // ── PRBoard ──
      COL_EXERCISE: "MASHQ",
      COL_WEIGHT: "VAZN",
      COL_REPS: "TAKRORLAR",
      NO_RECORDS_YET: "Hali rekord yo'q — ularni qo'lga kirit.",
      PR_BOARD_ARIA: "Shaxsiy rekordlar jadvali",

      // ── PRWall ──
      PERSONAL_RECORDS_LABEL: "SHAXSIY REKORDLAR",
      NO_PRS_FORGE: "Hali rekord yo'q — po'lat quyishni davom et",
      PERSONAL_RECORD_CARD: "SHAXSIY REKORD",
      REPS_LABEL: "takr.",
      PERSONAL_BEST: "SHAXSIY ENG YAXSHI",

      // ── AchievementsBoard ──
      LOCKED: "— BLOKLANGAN —",

      // ── CalendarHeatmap ──
      HEATMAP_ARIA: "Mashq chastotasi xaritasi",
      HEATMAP_SESSION: "mashg'ulot",
      HEATMAP_SESSIONS: "mashg'ulot",
      HEATMAP_LESS: "KAM",
      HEATMAP_MORE: "KO'P",

      // ── MuscleRadar ──
      MUSCLE_DISTRIBUTION_LABEL: "MUSHAK TAQSIMOTI — HAJM %",
      MUSCLE_RADAR_BADGE: "MUSHAK RADARI",
      OF_VOLUME: "% hajm",
      HIGHEST: "(yetakchi)",

      // ── EnhancedVolumeChart ──
      INSUFFICIENT_DATA: "Ma'lumot yetarli emas — ko'proq mashg'ulot yozing",
      PEAK: "Cho'qqi",
      AVG: "O'rtacha",
      SESSIONS_LABEL: "Mashg'ulot",
      TOOLTIP_VOLUME: "Hajm",
      TOOLTIP_AVG_RPE: "O'rt. RPE",
      TOOLTIP_SESSIONS: "Mashg'ulot",

      // ── ProgressTrendChart ──
      LEGEND_MAX_E1RM: "Maks. e1RM (kg)",
      LEGEND_AVG_RPE: "O'rt. RPE",
      TOOLTIP_MAX_E1RM: "Maks. e1RM",
      TOOLTIP_TOTAL_SETS: "Jami yondashuvlar",

      // ── RepsDistributionChart ──
      NO_REP_DATA: "Takror ma'lumoti yo'q — ko'proq yondashuv yozing",
      TOOLTIP_REPS_SUFFIX: "takr.",
      TOOLTIP_OCCURRENCES: "Holatlar",

      // ── MuscleBalance ──
      NO_SPLIT_DATA: "SPLIT MA'LUMOTI YO'Q",
      PUSH_LABEL: "ITARISH",
      PULL_LABEL: "TORTISH",
      LEGS_LABEL: "OYOQ",

      // ── DonutBreakdown ──
      SPLIT_LABEL: "SPLIT",

      // ── VolumeStackedChart tooltip ──
      TOTAL_LABEL: "JAMI",

      // ── MusclePieChart ──
      NO_DATA_DISTRIBUTION: "MA'LUMOT YO'Q",
      LOG_WORKOUTS_DISTRIBUTION: "TAQSIMOTNI KO'RISH UCHUN MASHQLARNI YOZING",
      TOTAL_CENTER: "JAMI",

      // ── StreakTracker (component-level) ──
      STREAK_DAY_STREAK: "Kunlik seriya",
      STREAK_BEST_STREAK: "Eng yaxshi seriya",
      STREAK_THIS_WEEK: "Bu hafta",
      STREAK_TOTAL_SESSIONS: "Jami mashg'ulotlar",

      // ── MuscleDistribution (component-level) ──
      LOG_FOR_DISTRIBUTION: "Taqsimotni ko'rish uchun mashg'ulotlarni yozing.",
      SESSIONS_TOOLTIP: "mashg'ulot",

      // ── LiftProgressionChart (component-level) ──
      LOG_FOR_PROGRESSION: "Progressiyani kuzatish uchun mashg'ulotlarni yozing.",

      // ── VolumeChart (component-level) ──
      NO_DATA_VOLUME: "Hali ma'lumot yo'q. Hajmni ko'rish uchun mashg'ulot yozing.",
      VOLUME_TOOLTIP: "Hajm",
    },
    muscles: {
      ARMS: "Qo'llar",
    },
  },
};

export default additions;
