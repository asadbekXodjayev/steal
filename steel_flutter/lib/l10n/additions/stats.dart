// Localization additions for the Stats / Progress vertical.
// Owned by the stats feature agent. Keys deep-merged into base strings.
// Every key MUST exist in EN, RU and UZ with identical shapes.

const Map<String, dynamic> statsEn = {
  'stats': {
    'TITLE': 'STATS',
    'EYEBROW_LEFT': 'ANALYTICS',
    'EYEBROW_RIGHT': 'FORGED IN IRON',
    'LAST_SYNC': 'LAST SYNC',

    // States
    'SIGNAL_LOST': 'SIGNAL LOST',
    'SIGNAL_LOST_DESC': 'Could not pull your training data',
    'NO_DATA_TITLE': 'No training logged yet — start a session',
    'NO_DATA_DESC': 'Complete a workout to unlock your analytics',
    'INSUFFICIENT_DATA': 'INSUFFICIENT DATA',

    // KPI row
    'KPI': 'KEY METRICS',
    'READOUT': 'READOUT',
    'TOTAL_SESSIONS': 'TOTAL SESSIONS',
    'LIFETIME': 'LIFETIME',
    'CURRENT_STREAK': 'CURRENT STREAK',
    'LONGEST_STREAK': 'LONGEST STREAK',
    'BEST': 'BEST',
    'TOTAL_VOLUME': 'TOTAL VOLUME',
    'THIS_MONTH': 'THIS MONTH',
    'THIS_WEEK': 'THIS WEEK',
    'THIS_WK': 'THIS WK',
    'TOTAL': 'TOTAL',
    'DAYS': 'DAYS',
    'TONNES': 'TONNES',

    // Streak section
    'CONSISTENCY': 'CONSISTENCY',
    'STREAK_SESSIONS': 'STREAK & SESSIONS',

    // Volume chart
    'WEEKLY_VOLUME': 'WEEKLY VOLUME',
    'LAST_8_WEEKS': 'LAST 8 WEEKS',
    'PEAK': 'PEAK',
    'AVG': 'AVG',
    'SESSIONS_LABEL': 'SESSIONS',

    // Reps distribution
    'REP_DISTRIBUTION': 'REP DISTRIBUTION',
    'INTENSITY_PROFILE': 'INTENSITY PROFILE',
    'NO_REP_DATA': 'NO REP DATA',
    'SETS_LABEL': 'SETS',

    // Calendar heatmap
    'CONTACT_MATRIX': 'CONTACT MATRIX',
    'YEAR_LABEL': 'YEAR',
    'HEATMAP_LESS': 'LESS',
    'HEATMAP_MORE': 'MORE',
    'HEATMAP_SESSION': 'session',
    'HEATMAP_SESSIONS': 'sessions',

    // Muscle map
    'VOLUME_BREAKDOWN': 'VOLUME BREAKDOWN',
    'MUSCLE_MAP': 'MUSCLE MAP',
    'MUSCLE_BALANCE': 'MUSCLE BALANCE',
    'TRAINING_DISTRIBUTION': 'TRAINING DISTRIBUTION',
    'NO_MUSCLE_DATA': 'NO MUSCLE DATA',

    // Personal records
    'PERSONAL_BESTS': 'PERSONAL BESTS',
    'RECORDS': 'RECORDS',
    'EXERCISE': 'EXERCISE',
    'BEST_SET': 'BEST SET',
    'EST_1RM': 'EST 1RM',

    // HUD strip
    'TOTAL_REPS': 'TOTAL REPS',
    'REPS_LOGGED': 'REPS LOGGED',
    'AVG_RPE': 'AVG RPE',
    'INTENSITY_10': 'INTENSITY / 10',
    'HEAVIEST_SET': 'HEAVIEST SET',
    'NO_DATA': 'NO DATA',

    // Muscle group names
    'muscle': {
      'CHEST': 'CHEST',
      'BACK': 'BACK',
      'SHOULDER': 'SHOULDERS',
      'BICEP': 'BICEPS',
      'TRICEP': 'TRICEPS',
      'QUAD': 'QUADS',
      'HAMSTRING': 'HAMSTRINGS',
      'GLUTE': 'GLUTES',
      'CALF': 'CALVES',
      'TRAP': 'TRAPS',
      'ABS': 'ABS',
      'OTHER': 'OTHER',
    },
  },
};

const Map<String, dynamic> statsRu = {
  'stats': {
    'TITLE': 'СТАТИСТИКА',
    'EYEBROW_LEFT': 'АНАЛИТИКА',
    'EYEBROW_RIGHT': 'ВЫКОВАНО В ЖЕЛЕЗЕ',
    'LAST_SYNC': 'СИНХРОНИЗАЦИЯ',

    'SIGNAL_LOST': 'СИГНАЛ ПОТЕРЯН',
    'SIGNAL_LOST_DESC': 'Не удалось загрузить данные тренировок',
    'NO_DATA_TITLE': 'Тренировок пока нет — начни сессию',
    'NO_DATA_DESC': 'Заверши тренировку, чтобы открыть аналитику',
    'INSUFFICIENT_DATA': 'НЕДОСТАТОЧНО ДАННЫХ',

    'KPI': 'КЛЮЧЕВЫЕ МЕТРИКИ',
    'READOUT': 'СВОДКА',
    'TOTAL_SESSIONS': 'ВСЕГО СЕССИЙ',
    'LIFETIME': 'ЗА ВСЁ ВРЕМЯ',
    'CURRENT_STREAK': 'ТЕКУЩАЯ СЕРИЯ',
    'LONGEST_STREAK': 'ЛУЧШАЯ СЕРИЯ',
    'BEST': 'РЕКОРД',
    'TOTAL_VOLUME': 'ОБЩИЙ ТОННАЖ',
    'THIS_MONTH': 'ЗА МЕСЯЦ',
    'THIS_WEEK': 'ЗА НЕДЕЛЮ',
    'THIS_WK': 'НЕД.',
    'TOTAL': 'ВСЕГО',
    'DAYS': 'ДНЕЙ',
    'TONNES': 'ТОНН',

    'CONSISTENCY': 'ПОСТОЯНСТВО',
    'STREAK_SESSIONS': 'СЕРИЯ И СЕССИИ',

    'WEEKLY_VOLUME': 'НЕДЕЛЬНЫЙ ТОННАЖ',
    'LAST_8_WEEKS': 'ПОСЛЕДНИЕ 8 НЕДЕЛЬ',
    'PEAK': 'ПИК',
    'AVG': 'СРЕДН',
    'SESSIONS_LABEL': 'СЕССИИ',

    'REP_DISTRIBUTION': 'РАСПРЕДЕЛЕНИЕ ПОВТОРОВ',
    'INTENSITY_PROFILE': 'ПРОФИЛЬ ИНТЕНСИВНОСТИ',
    'NO_REP_DATA': 'НЕТ ДАННЫХ О ПОВТОРАХ',
    'SETS_LABEL': 'ПОДХОДЫ',

    'CONTACT_MATRIX': 'МАТРИЦА АКТИВНОСТИ',
    'YEAR_LABEL': 'ГОД',
    'HEATMAP_LESS': 'МЕНЬШЕ',
    'HEATMAP_MORE': 'БОЛЬШЕ',
    'HEATMAP_SESSION': 'сессия',
    'HEATMAP_SESSIONS': 'сессий',

    'VOLUME_BREAKDOWN': 'РАЗБИВКА ТОННАЖА',
    'MUSCLE_MAP': 'КАРТА МЫШЦ',
    'MUSCLE_BALANCE': 'БАЛАНС МЫШЦ',
    'TRAINING_DISTRIBUTION': 'РАСПРЕДЕЛЕНИЕ НАГРУЗКИ',
    'NO_MUSCLE_DATA': 'НЕТ ДАННЫХ О МЫШЦАХ',

    'PERSONAL_BESTS': 'ЛИЧНЫЕ РЕКОРДЫ',
    'RECORDS': 'РЕКОРДЫ',
    'EXERCISE': 'УПРАЖНЕНИЕ',
    'BEST_SET': 'ЛУЧШИЙ ПОДХОД',
    'EST_1RM': 'ОЦЕНКА 1ПМ',

    'TOTAL_REPS': 'ВСЕГО ПОВТОРОВ',
    'REPS_LOGGED': 'ПОВТОРОВ ЗАПИСАНО',
    'AVG_RPE': 'СРЕДН RPE',
    'INTENSITY_10': 'ИНТЕНСИВНОСТЬ / 10',
    'HEAVIEST_SET': 'САМЫЙ ТЯЖЁЛЫЙ',
    'NO_DATA': 'НЕТ ДАННЫХ',

    'muscle': {
      'CHEST': 'ГРУДЬ',
      'BACK': 'СПИНА',
      'SHOULDER': 'ПЛЕЧИ',
      'BICEP': 'БИЦЕПС',
      'TRICEP': 'ТРИЦЕПС',
      'QUAD': 'КВАДРИЦЕПС',
      'HAMSTRING': 'БИЦЕПС БЕДРА',
      'GLUTE': 'ЯГОДИЦЫ',
      'CALF': 'ИКРЫ',
      'TRAP': 'ТРАПЕЦИИ',
      'ABS': 'ПРЕСС',
      'OTHER': 'ДРУГОЕ',
    },
  },
};

const Map<String, dynamic> statsUz = {
  'stats': {
    'TITLE': 'STATISTIKA',
    'EYEBROW_LEFT': 'TAHLIL',
    'EYEBROW_RIGHT': 'TEMIRDA TOBLANGAN',
    'LAST_SYNC': 'OXIRGI SINXRON',

    'SIGNAL_LOST': 'SIGNAL YO\'QOLDI',
    'SIGNAL_LOST_DESC': 'Mashg\'ulot ma\'lumotlarini yuklab bo\'lmadi',
    'NO_DATA_TITLE': 'Hali mashg\'ulot yo\'q — sessiyani boshlang',
    'NO_DATA_DESC': 'Tahlilni ochish uchun mashqni yakunlang',
    'INSUFFICIENT_DATA': 'MA\'LUMOT YETARLI EMAS',

    'KPI': 'ASOSIY KO\'RSATKICHLAR',
    'READOUT': 'HISOBOT',
    'TOTAL_SESSIONS': 'JAMI SESSIYALAR',
    'LIFETIME': 'BUTUN DAVR',
    'CURRENT_STREAK': 'JORIY SERIYA',
    'LONGEST_STREAK': 'ENG UZUN SERIYA',
    'BEST': 'REKORD',
    'TOTAL_VOLUME': 'UMUMIY TONNAJ',
    'THIS_MONTH': 'SHU OY',
    'THIS_WEEK': 'SHU HAFTA',
    'THIS_WK': 'HAFTA',
    'TOTAL': 'JAMI',
    'DAYS': 'KUN',
    'TONNES': 'TONNA',

    'CONSISTENCY': 'IZCHILLIK',
    'STREAK_SESSIONS': 'SERIYA VA SESSIYALAR',

    'WEEKLY_VOLUME': 'HAFTALIK TONNAJ',
    'LAST_8_WEEKS': 'OXIRGI 8 HAFTA',
    'PEAK': 'CHO\'QQI',
    'AVG': 'O\'RTACHA',
    'SESSIONS_LABEL': 'SESSIYALAR',

    'REP_DISTRIBUTION': 'TAKROR TAQSIMOTI',
    'INTENSITY_PROFILE': 'INTENSIVLIK PROFILI',
    'NO_REP_DATA': 'TAKROR MA\'LUMOTI YO\'Q',
    'SETS_LABEL': 'YONDASHUVLAR',

    'CONTACT_MATRIX': 'FAOLLIK MATRITSASI',
    'YEAR_LABEL': 'YIL',
    'HEATMAP_LESS': 'KAMROQ',
    'HEATMAP_MORE': 'KO\'PROQ',
    'HEATMAP_SESSION': 'sessiya',
    'HEATMAP_SESSIONS': 'sessiya',

    'VOLUME_BREAKDOWN': 'TONNAJ TAQSIMOTI',
    'MUSCLE_MAP': 'MUSKUL XARITASI',
    'MUSCLE_BALANCE': 'MUSKUL BALANSI',
    'TRAINING_DISTRIBUTION': 'YUKLAMA TAQSIMOTI',
    'NO_MUSCLE_DATA': 'MUSKUL MA\'LUMOTI YO\'Q',

    'PERSONAL_BESTS': 'SHAXSIY REKORDLAR',
    'RECORDS': 'REKORDLAR',
    'EXERCISE': 'MASHQ',
    'BEST_SET': 'ENG YAXSHI YONDASHUV',
    'EST_1RM': 'TAXM 1RM',

    'TOTAL_REPS': 'JAMI TAKRORLAR',
    'REPS_LOGGED': 'TAKROR QAYD ETILDI',
    'AVG_RPE': 'O\'RTACHA RPE',
    'INTENSITY_10': 'INTENSIVLIK / 10',
    'HEAVIEST_SET': 'ENG OG\'IR YONDASHUV',
    'NO_DATA': 'MA\'LUMOT YO\'Q',

    'muscle': {
      'CHEST': 'KO\'KRAK',
      'BACK': 'ORQA',
      'SHOULDER': 'YELKA',
      'BICEP': 'BITSEPS',
      'TRICEP': 'TRITSEPS',
      'QUAD': 'KVADRITSEPS',
      'HAMSTRING': 'SON ORQASI',
      'GLUTE': 'DUMBA',
      'CALF': 'BOLDIR',
      'TRAP': 'TRAPETSIYA',
      'ABS': 'PRESS',
      'OTHER': 'BOSHQA',
    },
  },
};
