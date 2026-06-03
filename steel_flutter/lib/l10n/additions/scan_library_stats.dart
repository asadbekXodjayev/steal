// Localization scan-pass additions — Library + Exercise detail + Stats vertical.
// Keys deep-merged into base strings. Every key MUST exist in EN, RU and UZ.
//
// `library.filter.*` localizes the DISPLAY of the library filter chips. The
// constant values in library_screen.dart (e.g. 'ANY EQUIP.', 'BARBELL') stay
// the canonical filter KEYS; the chip row looks the label up via
// `t('library.filter.$item')`, so filtering logic is untouched.

const Map<String, dynamic> scanLibraryStatsEn = {
  'library': {
    'filter': {
      // Muscle categories
      'ALL': 'ALL',
      'BACK': 'BACK',
      'CHEST': 'CHEST',
      'LEGS': 'LEGS',
      'SHOULDERS': 'SHOULDERS',
      'BICEPS': 'BICEPS',
      'TRICEPS': 'TRICEPS',
      'ABS': 'ABS',
      'GLUTES': 'GLUTES',
      'CARDIO': 'CARDIO',
      // Equipment
      'ANY EQUIP.': 'ANY EQUIP.',
      'ASSISTED': 'ASSISTED',
      'BAND': 'BAND',
      'BARBELL': 'BARBELL',
      'BODYWEIGHT': 'BODYWEIGHT',
      'DUMBBELL': 'DUMBBELL',
      'MACHINE': 'MACHINE',
      'KETTLEBELL': 'KETTLEBELL',
      // Muscle filter
      'ALL MUSCLES': 'ALL MUSCLES',
      'ABDUCTORS': 'ABDUCTORS',
      'ADDUCTORS': 'ADDUCTORS',
      'HAMSTRINGS': 'HAMSTRINGS',
      'QUADRICEPS': 'QUADRICEPS',
    },
  },
  'stats': {
    'KG': 'KG',
    // Heaviest-set caption: "KG × {n}" reps.
    'HEAVIEST_CAPTION': 'KG × {n}',
  },
};

const Map<String, dynamic> scanLibraryStatsRu = {
  'library': {
    'filter': {
      'ALL': 'ВСЕ',
      'BACK': 'СПИНА',
      'CHEST': 'ГРУДЬ',
      'LEGS': 'НОГИ',
      'SHOULDERS': 'ПЛЕЧИ',
      'BICEPS': 'БИЦЕПС',
      'TRICEPS': 'ТРИЦЕПС',
      'ABS': 'ПРЕСС',
      'GLUTES': 'ЯГОДИЦЫ',
      'CARDIO': 'КАРДИО',
      'ANY EQUIP.': 'ЛЮБОЙ ИНВ.',
      'ASSISTED': 'С ПОМОЩЬЮ',
      'BAND': 'РЕЗИНА',
      'BARBELL': 'ШТАНГА',
      'BODYWEIGHT': 'СВОЙ ВЕС',
      'DUMBBELL': 'ГАНТЕЛИ',
      'MACHINE': 'ТРЕНАЖЁР',
      'KETTLEBELL': 'ГИРЯ',
      'ALL MUSCLES': 'ВСЕ МЫШЦЫ',
      'ABDUCTORS': 'ОТВОДЯЩИЕ',
      'ADDUCTORS': 'ПРИВОДЯЩИЕ',
      'HAMSTRINGS': 'БИЦЕПС БЕДРА',
      'QUADRICEPS': 'КВАДРИЦЕПС',
    },
  },
  'stats': {
    'KG': 'КГ',
    'HEAVIEST_CAPTION': 'КГ × {n}',
  },
};

const Map<String, dynamic> scanLibraryStatsUz = {
  'library': {
    'filter': {
      'ALL': 'HAMMASI',
      'BACK': 'ORQA',
      'CHEST': 'KO\'KRAK',
      'LEGS': 'OYOQLAR',
      'SHOULDERS': 'YELKA',
      'BICEPS': 'BITSEPS',
      'TRICEPS': 'TRITSEPS',
      'ABS': 'PRESS',
      'GLUTES': 'DUMBA',
      'CARDIO': 'KARDIO',
      'ANY EQUIP.': 'HAR QANDAY',
      'ASSISTED': 'YORDAM BILAN',
      'BAND': 'REZINA',
      'BARBELL': 'SHTANGA',
      'BODYWEIGHT': 'TANA VAZNI',
      'DUMBBELL': 'GANTEL',
      'MACHINE': 'TRENAJYOR',
      'KETTLEBELL': 'GIRYA',
      'ALL MUSCLES': 'BARCHA MUSKULLAR',
      'ABDUCTORS': 'UZOQLASHTIRUVCHI',
      'ADDUCTORS': 'YAQINLASHTIRUVCHI',
      'HAMSTRINGS': 'SON ORQASI',
      'QUADRICEPS': 'KVADRITSEPS',
    },
  },
  'stats': {
    'KG': 'KG',
    'HEAVIEST_CAPTION': 'KG × {n}',
  },
};
