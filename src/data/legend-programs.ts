export interface Exercise {
  name: string;
  imagePlaceholder: string;
  sets: string;
  reps: string;
  rest: string;
  tempo?: string;
  notes: string;
}

export interface TrainingDay {
  name: string;
  focus: string;
  exercises: Exercise[];
}

export interface LegendProgram {
  id: string;
  name: string;
  athleteName: string;
  philosophy: string;
  frequency: string;
  split: string;
  weeklyVolume: Record<string, string>;
  recommendedFor: string;
  sessionLength: string;
  schedule: { day: string; workout: string }[];
  trainingDays: TrainingDay[];
  progression: string[];
  deload: string;
  recovery: string[];
  image: string;
  tags: string[];
}

export const LEGEND_PROGRAMS: LegendProgram[] = [
  {
    id: "arnold",
    name: "Arnold Schwarzenegger Style",
    athleteName: "Arnold Schwarzenegger",
    philosophy: "Arnold Schwarzenegger, the legendary Austrian Oak, won 7 Mr. Olympia titles and revolutionized bodybuilding with his classic physique and unparalleled work ethic. His training philosophy centered on high-volume, pump-focused bodybuilding with multiple exercises per muscle group, 8-12 rep ranges, and an emphasis on mind-muscle connection.",
    frequency: "6 days per week",
    split: "Classic Body Part Split",
    weeklyVolume: { chest: "18-22 sets", back: "20-24 sets", shoulders: "16-20 sets", legs: "20-24 sets", arms: "20-26 sets" },
    recommendedFor: "Intermediate to advanced lifters seeking maximum hypertrophy",
    sessionLength: "75-90 minutes",
    schedule: [
      { day: "Monday", workout: "Chest & Back" },
      { day: "Tuesday", workout: "Shoulders" },
      { day: "Wednesday", workout: "Legs" },
      { day: "Thursday", workout: "Arms" },
      { day: "Friday", workout: "Upper Body Pump" },
      { day: "Saturday", workout: "Chest & Back (Volume)" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Chest & Back (Heavy Compounds)",
        exercises: [
          { name: "Barbell Bench Press", imagePlaceholder: "Barbell Bench Press", sets: "2 warm-up + 4", reps: "8-10", rest: "2-3 min", tempo: "2-0-1-0", notes: "Arnold's Golden 6 staple" },
          { name: "Barbell Row", imagePlaceholder: "Barbell Row", sets: "2 warm-up + 4", reps: "8-10", rest: "2-3 min", tempo: "2-0-1-0", notes: "Thick back builder" },
          { name: "Incline Dumbbell Press", imagePlaceholder: "Incline Dumbbell Press", sets: "3", reps: "10-12", rest: "90 sec", tempo: "3-0-1-0", notes: "Upper chest development" },
          { name: "Wide-Grip Pull-Up", imagePlaceholder: "Wide-Grip Pull-Up", sets: "4", reps: "8-12", rest: "90 sec", tempo: "3-0-1-0", notes: "V-taper width" },
          { name: "Flat Dumbbell Flyes", imagePlaceholder: "Flat Dumbbell Flyes", sets: "3", reps: "12-15", rest: "60 sec", tempo: "3-1-1-0", notes: "Chest isolation" },
          { name: "T-Bar Row", imagePlaceholder: "T-Bar Row", sets: "3", reps: "10-12", rest: "90 sec", tempo: "2-1-1-0", notes: "Mid-back thickness" },
        ],
      },
      {
        name: "Day 2",
        focus: "Shoulders (Boulder Shoulders)",
        exercises: [
          { name: "Standing Barbell Overhead Press", imagePlaceholder: "Standing Barbell Overhead Press", sets: "2 warm-up + 4", reps: "8-10", rest: "2-3 min", tempo: "2-0-1-0", notes: "Classic mass builder" },
          { name: "Arnold Press", imagePlaceholder: "Arnold Press", sets: "3", reps: "10-12", rest: "90 sec", tempo: "2-0-1-0", notes: "Signature movement" },
          { name: "Dumbbell Lateral Raise", imagePlaceholder: "Dumbbell Lateral Raise", sets: "4", reps: "12-15", rest: "60 sec", tempo: "2-1-1-0", notes: "Side delt width" },
          { name: "Bent-Over Lateral Raise", imagePlaceholder: "Bent-Over Lateral Raise", sets: "3", reps: "15-20", rest: "60 sec", tempo: "2-1-1-0", notes: "Rear delt development" },
          { name: "Upright Row", imagePlaceholder: "Upright Row", sets: "3", reps: "10-12", rest: "90 sec", tempo: "2-0-1-0", notes: "Traps and side delts" },
        ],
      },
      {
        name: "Day 3",
        focus: "Legs (Iron Paradise)",
        exercises: [
          { name: "Barbell Back Squat", imagePlaceholder: "Barbell Back Squat", sets: "3 warm-up + 4", reps: "8-10", rest: "3 min", tempo: "3-0-1-0", notes: "Ultimate leg mass builder" },
          { name: "Leg Press", imagePlaceholder: "Leg Press", sets: "3", reps: "12-15", rest: "90 sec", tempo: "2-1-1-0", notes: "Quad volume" },
          { name: "Leg Extension", imagePlaceholder: "Leg Extension", sets: "3", reps: "15-20", rest: "60 sec", tempo: "2-1-1-0", notes: "Quad isolation" },
          { name: "Lying Leg Curl", imagePlaceholder: "Lying Leg Curl", sets: "3", reps: "12-15", rest: "60 sec", tempo: "2-1-1-0", notes: "Hamstring development" },
          { name: "Standing Calf Raise", imagePlaceholder: "Standing Calf Raise", sets: "5", reps: "10-15", rest: "60 sec", tempo: "2-1-2-0", notes: "Calf development" },
          { name: "Seated Calf Raise", imagePlaceholder: "Seated Calf Raise", sets: "4", reps: "15-20", rest: "60 sec", tempo: "2-1-2-0", notes: "Soleus development" },
        ],
      },
      {
        name: "Day 4",
        focus: "Arms (Arms Day Special)",
        exercises: [
          { name: "Barbell Curl", imagePlaceholder: "Barbell Curl", sets: "2 warm-up + 4", reps: "8-10", rest: "90 sec", tempo: "2-0-1-0", notes: "Classic bicep mass builder" },
          { name: "Preacher Curl", imagePlaceholder: "Preacher Curl", sets: "3", reps: "10-12", rest: "60 sec", tempo: "2-1-1-0", notes: "Strict bicep isolation" },
          { name: "Incline Dumbbell Curl", imagePlaceholder: "Incline Dumbbell Curl", sets: "3", reps: "10-12", rest: "60 sec", tempo: "3-0-1-0", notes: "Long head bicep stretch" },
          { name: "Close-Grip Bench Press", imagePlaceholder: "Close-Grip Bench Press", sets: "2 warm-up + 3", reps: "8-10", rest: "90 sec", tempo: "2-0-1-0", notes: "Tricep mass builder" },
          { name: "Skull Crusher", imagePlaceholder: "Skull Crusher", sets: "3", reps: "10-12", rest: "60 sec", tempo: "2-1-1-0", notes: "Long head tricep" },
          { name: "Tricep Pushdown", imagePlaceholder: "Tricep Pushdown", sets: "3", reps: "15-20", rest: "60 sec", tempo: "2-0-1-0", notes: "Tricep pump finisher" },
          { name: "Hammer Curl", imagePlaceholder: "Hammer Curl", sets: "3", reps: "10-12", rest: "60 sec", tempo: "2-1-1-0", notes: "Brachialis development" },
        ],
      },
    ],
    progression: [
      "Add 2.5-5 lbs when hitting top of rep range",
      "Prioritize form and mind-muscle connection",
      "Track workouts weekly for progressive overload",
    ],
    deload: "Every 6-8 weeks, reduce volume by 50% for one week",
    recovery: [
      "Sleep 7-9 hours nightly",
      "Consume 1g protein per lb of bodyweight",
      "Stay hydrated — minimum 1 gallon water daily",
    ],
    image: "/legends/arnold.jpg",
    tags: ["Classic Bodybuilding", "High Volume", "Pump Focus"],
  },
  {
    id: "platz",
    name: "Tom Platz Style",
    athleteName: "Tom Platz",
    philosophy: "Tom Platz, the 'Quad God', possessed the most legendary legs in bodybuilding history. His training philosophy was built on extreme intensity, brutal leg specialization, and an unparalleled work ethic that pushed beyond human limits. Platz trained with high-rep squats (20-50 reps) and drop sets.",
    frequency: "5 days per week",
    split: "Quad Specialization Split",
    weeklyVolume: { quads: "24-30 sets", hamstrings: "16-20 sets", chest: "14-18 sets", back: "16-20 sets", shoulders: "12-16 sets", arms: "14-18 sets" },
    recommendedFor: "Advanced lifters with exceptional leg development goals",
    sessionLength: "75-105 minutes",
    schedule: [
      { day: "Monday", workout: "Quad Specialization" },
      { day: "Tuesday", workout: "Upper Body" },
      { day: "Wednesday", workout: "Hamstring & Glute" },
      { day: "Thursday", workout: "Upper Body" },
      { day: "Friday", workout: "Quad Devastation" },
      { day: "Saturday", workout: "Rest" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Quad Specialization",
        exercises: [
          { name: "Barbell Back Squat", imagePlaceholder: "Barbell Back Squat", sets: "4 warm-up + 1", reps: "20", rest: "5-7 min", tempo: "4-0-1-0", notes: "Legendary high-rep squat" },
          { name: "Hack Squat", imagePlaceholder: "Hack Squat", sets: "2 warm-up + 3", reps: "12-15", rest: "2-3 min", tempo: "3-0-1-0", notes: "Quad focus" },
          { name: "Leg Extension", imagePlaceholder: "Leg Extension", sets: "4", reps: "20-30", rest: "90 sec", tempo: "2-1-2-0", notes: "Extreme high-rep burnout" },
          { name: "Bulgarian Split Squat", imagePlaceholder: "Bulgarian Split Squat", sets: "3", reps: "12-15 each", rest: "90 sec", tempo: "2-1-1-0", notes: "Unilateral quad work" },
          { name: "Walking Lunge", imagePlaceholder: "Walking Lunge", sets: "3", reps: "20 steps", rest: "90 sec", tempo: "2-0-1-0", notes: "Functional quad development" },
        ],
      },
    ],
    progression: [
      "Add 1-2 reps weekly on high-rep squats",
      "Add 5 lbs on heavy compounds when hitting top rep range",
      "Track RPE — leg days should be RPE 9-10",
    ],
    deload: "Every 4-6 weeks, reduce leg volume by 50%",
    recovery: [
      "Prioritize sleep (8-9 hours)",
      "Post-workout nutrition within 30 minutes",
      "Consider glutamine and BCAAs during training",
    ],
    image: "/legends/platz.jpg",
    tags: ["Quad Focus", "High Intensity", "Extreme Volume"],
  },
  {
    id: "piana",
    name: "Rich Piana Style",
    athleteName: "Rich Piana",
    philosophy: "Rich Piana was known for his extreme volume training, long workouts, and '5000 Calories' mentality. His approach emphasized high-intensity techniques like drop sets and supersets, training with a 'no days off' mentality. Rich believed in pushing past conventional limits.",
    frequency: "6 days per week",
    split: "High Volume Split",
    weeklyVolume: { chest: "20-24 sets", back: "20-24 sets", legs: "20-24 sets", shoulders: "18-22 sets", arms: "22-28 sets" },
    recommendedFor: "Advanced lifters with high recovery capacity",
    sessionLength: "90-120 minutes",
    schedule: [
      { day: "Monday", workout: "Chest" },
      { day: "Tuesday", workout: "Back" },
      { day: "Wednesday", workout: "Legs" },
      { day: "Thursday", workout: "Shoulders" },
      { day: "Friday", workout: "Arms" },
      { day: "Saturday", workout: "Full Body Pump" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Chest (Volume Destruction)",
        exercises: [
          { name: "Incline Dumbbell Press", imagePlaceholder: "Incline Dumbbell Press", sets: "2 warm-up + 4", reps: "10-12", rest: "90 sec", tempo: "3-0-1-0", notes: "Upper chest focus" },
          { name: "Flat Dumbbell Press", imagePlaceholder: "Flat Dumbbell Press", sets: "3", reps: "10-12", rest: "90 sec", tempo: "2-0-1-0", notes: "Overall chest mass" },
          { name: "Cable Crossover", imagePlaceholder: "Cable Crossover", sets: "4", reps: "15-20", rest: "60 sec", tempo: "2-1-1-0", notes: "Constant tension" },
          { name: "Incline Cable Flye", imagePlaceholder: "Incline Cable Flye", sets: "3", reps: "15-20", rest: "60 sec", tempo: "2-1-1-0", notes: "Upper chest isolation" },
          { name: "Dips", imagePlaceholder: "Dips", sets: "3", reps: "12-15", rest: "90 sec", tempo: "2-0-1-0", notes: "Lower chest and tricep" },
          { name: "Pec Deck Flye", imagePlaceholder: "Pec Deck Flye", sets: "3", reps: "20-25", rest: "60 sec", tempo: "2-1-2-0", notes: "Final pump" },
        ],
      },
    ],
    progression: [
      "Focus on adding reps first, then weight",
      "Track drop set performance",
      "Keep a detailed training log",
    ],
    deload: "Every 5-6 weeks, reduce volume by 40%",
    recovery: [
      "Sleep 8+ hours",
      "1g+ protein per lb bodyweight",
      "Minimum 1 gallon water daily",
    ],
    image: "/legends/piana.jpg",
    tags: ["Extreme Volume", "High Intensity", "Drop Sets"],
  },
  {
    id: "mentzer",
    name: "Mike Mentzer Style (Heavy Duty HIT)",
    athleteName: "Mike Mentzer",
    philosophy: "Mike Mentzer pioneered Heavy Duty HIT training — one all-out working set per exercise to absolute failure. His philosophy emphasized maximum intensity with minimum volume, heavy weights, and extended recovery. Mentzer believed growth happens during recovery, not training.",
    frequency: "4 days per week",
    split: "HIT Split",
    weeklyVolume: { chest: "6-8 sets", back: "8-10 sets", shoulders: "6-8 sets", legs: "8-10 sets", arms: "6-8 sets" },
    recommendedFor: "Advanced lifters who prefer low volume, maximum intensity",
    sessionLength: "30-45 minutes",
    schedule: [
      { day: "Monday", workout: "Chest/Back HIT" },
      { day: "Tuesday", workout: "Rest" },
      { day: "Wednesday", workout: "Shoulders/Arms HIT" },
      { day: "Thursday", workout: "Rest" },
      { day: "Friday", workout: "Legs HIT" },
      { day: "Saturday", workout: "Rest" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Chest + Back (HIT Supersets)",
        exercises: [
          { name: "Incline Dumbbell Press", imagePlaceholder: "Incline Dumbbell Press", sets: "2-3 warm-up + 1", reps: "6-10 to failure", rest: "3-4 min", tempo: "4-0-1-0", notes: "Heavy Duty chest" },
          { name: "Close-Grip Pulldown", imagePlaceholder: "Close-Grip Pulldown", sets: "2 warm-up + 1", reps: "8-12 to failure", rest: "3-4 min", tempo: "4-0-1-0", notes: "Heavy Duty back" },
          { name: "Flat Barbell Bench Press", imagePlaceholder: "Flat Barbell Bench Press", sets: "2 warm-up + 1", reps: "6-8 to failure", rest: "3-4 min", tempo: "4-0-1-0", notes: "Maximum weight" },
          { name: "Barbell Row", imagePlaceholder: "Barbell Row", sets: "2 warm-up + 1", reps: "6-8 to failure", rest: "3-4 min", tempo: "4-0-1-0", notes: "Controlled eccentric" },
          { name: "Cable Flye", imagePlaceholder: "Cable Flye", sets: "1 warm-up + 1", reps: "10-15 to failure", rest: "2-3 min", tempo: "3-1-1-0", notes: "Stretch-focused" },
          { name: "Seated Cable Row", imagePlaceholder: "Seated Cable Row", sets: "1 warm-up + 1", reps: "10-15 to failure", rest: "2-3 min", tempo: "3-1-1-0", notes: "One set to failure" },
        ],
      },
    ],
    progression: [
      "Add weight when exceeding top of rep range",
      "Track every workout precisely",
      "Focus on intensity techniques: forced reps, negatives",
    ],
    deload: "HIT naturally incorporates deload through extended rest",
    recovery: [
      "Sleep 8-9 hours — critical for HIT",
      "Adequate protein and calories",
      "If progress stalls, reduce frequency further",
    ],
    image: "/legends/mentzer.jpg",
    tags: ["HIT", "Low Volume", "Maximum Intensity"],
  },
  {
    id: "yates",
    name: "Dorian Yates Style (Blood & Guts HIT)",
    athleteName: "Dorian Yates",
    philosophy: "Dorian Yates, the Shadow, won 6 consecutive Mr. Olympia titles with his Blood & Guts HIT style. One heavy working set per exercise with controlled negatives and brutal intensity defined his approach. Yates proved that less is more when intensity is maximized.",
    frequency: "5 days per week",
    split: "Blood & Guts HIT Split",
    weeklyVolume: { chest: "6-8 sets", back: "8-10 sets", shoulders: "6-8 sets", legs: "10-12 sets", arms: "6-8 sets" },
    recommendedFor: "Advanced lifters who want HIT with slightly more volume",
    sessionLength: "45-60 minutes",
    schedule: [
      { day: "Monday", workout: "Legs" },
      { day: "Tuesday", workout: "Chest/Back" },
      { day: "Wednesday", workout: "Shoulders/Arms" },
      { day: "Thursday", workout: "Rest" },
      { day: "Friday", workout: "Upper Heavy" },
      { day: "Saturday", workout: "Lower Heavy" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Legs (Blood & Guts Style)",
        exercises: [
          { name: "Hack Squat", imagePlaceholder: "Hack Squat", sets: "3-4 warm-up + 1", reps: "6-10 to failure", rest: "4-5 min", tempo: "4-0-1-0", notes: "Signature leg movement" },
          { name: "Leg Press", imagePlaceholder: "Leg Press", sets: "2 warm-up + 1", reps: "10-15 to failure", rest: "3-4 min", tempo: "3-1-1-0", notes: "Quad volume" },
          { name: "Leg Extension", imagePlaceholder: "Leg Extension", sets: "1 warm-up + 1", reps: "15-20 to failure", rest: "2-3 min", tempo: "2-1-2-0", notes: "Burnout set" },
          { name: "Romanian Deadlift", imagePlaceholder: "Romanian Deadlift", sets: "2 warm-up + 1", reps: "8-12 to failure", rest: "3-4 min", tempo: "4-1-1-0", notes: "Hamstring stretch" },
          { name: "Lying Leg Curl", imagePlaceholder: "Lying Leg Curl", sets: "1 warm-up + 1", reps: "10-15 to failure", rest: "2-3 min", tempo: "3-1-1-0", notes: "Hamstring isolation" },
          { name: "Seated Calf Raise", imagePlaceholder: "Seated Calf Raise", sets: "1", reps: "10-15 to failure", rest: "2 min", tempo: "3-1-2-0", notes: "Calf development" },
        ],
      },
    ],
    progression: [
      "Add weight when hitting top of rep range with good form",
      "Track working set weights",
      "Warm-up thoroughly — injury prevention is key",
    ],
    deload: "Every 4-6 weeks, reduce intensity to RPE 7-8",
    recovery: [
      "Sleep 8+ hours — non-negotiable",
      "High protein, adequate calories",
      "If joints ache, take an extra rest day",
    ],
    image: "/legends/yates.png",
    tags: ["Blood & Guts", "HIT", "Controlled Negatives"],
  },
  {
    id: "ronnie",
    name: "Ronnie Coleman Style",
    athleteName: "Ronnie Coleman",
    philosophy: "Ronnie Coleman, 'The King', won 8 consecutive Mr. Olympia titles with massive volume and heavy compounds. His 'Yeah Buddy!' work ethic and twice-per-week frequency on major muscles defined his approach. Ronnie proved that heavy weight and high reps can coexist.",
    frequency: "6 days per week",
    split: "High-Frequency Split",
    weeklyVolume: { chest: "18-22 sets", back: "20-24 sets", shoulders: "16-20 sets", legs: "20-24 sets", arms: "18-22 sets" },
    recommendedFor: "Advanced lifters with high recovery capacity",
    sessionLength: "75-90 minutes",
    schedule: [
      { day: "Monday", workout: "Chest/Back" },
      { day: "Tuesday", workout: "Shoulders/Arms" },
      { day: "Wednesday", workout: "Legs" },
      { day: "Thursday", workout: "Chest/Back" },
      { day: "Friday", workout: "Shoulders/Arms" },
      { day: "Saturday", workout: "Legs" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Chest + Back (Heavy Compounds)",
        exercises: [
          { name: "Barbell Bench Press", imagePlaceholder: "Barbell Bench Press", sets: "2 warm-up + 4", reps: "8-10", rest: "2-3 min", tempo: "2-0-1-0", notes: "Signature chest mass builder" },
          { name: "Barbell Row", imagePlaceholder: "Barbell Row", sets: "2 warm-up + 4", reps: "8-10", rest: "2-3 min", tempo: "2-0-1-0", notes: "Thick back builder" },
          { name: "Incline Dumbbell Press", imagePlaceholder: "Incline Dumbbell Press", sets: "3", reps: "10-12", rest: "90 sec", tempo: "3-0-1-0", notes: "Upper chest" },
          { name: "Wide-Grip Pull-Up", imagePlaceholder: "Wide-Grip Pull-Up", sets: "3", reps: "8-12", rest: "90 sec", tempo: "3-0-1-0", notes: "Back width" },
          { name: "Cable Crossover", imagePlaceholder: "Cable Crossover", sets: "3", reps: "15-20", rest: "60 sec", tempo: "2-1-1-0", notes: "Chest isolation" },
          { name: "Seated Cable Row", imagePlaceholder: "Seated Cable Row", sets: "3", reps: "12-15", rest: "90 sec", tempo: "2-1-1-0", notes: "Mid-back thickness" },
        ],
      },
    ],
    progression: [
      "Add weight when hitting top of rep range",
      "Track both weight and reps",
      "Progressive overload is key — Yeah Buddy!",
    ],
    deload: "Every 6-8 weeks, reduce volume by 40-50%",
    recovery: [
      "Sleep 8+ hours",
      "Eat 6-8 meals daily",
      "Minimum 1 gallon water daily",
    ],
    image: "/legends/ronnie.jpg",
    tags: ["High Frequency", "Heavy Compounds", "Maximum Mass"],
  },
  {
    id: "nippard",
    name: "Jeff Nippard Style (Science-Based)",
    athleteName: "Jeff Nippard",
    philosophy: "Jeff Nippard brings science-based programming to bodybuilding, combining evidence-based exercise selection with RIR-based intensity tracking. His approach emphasizes optimal rep ranges, excellent form and tempo, and machine/cable selections for constant tension. Science meets aesthetics.",
    frequency: "5 days per week",
    split: "Upper/Lower Hybrid",
    weeklyVolume: { chest: "14-18 sets", back: "16-20 sets", shoulders: "12-16 sets", legs: "18-22 sets", arms: "10-14 sets" },
    recommendedFor: "Intermediate to advanced lifters wanting evidence-based programming",
    sessionLength: "60-75 minutes",
    schedule: [
      { day: "Monday", workout: "Upper A (Strength)" },
      { day: "Tuesday", workout: "Lower A (Squat)" },
      { day: "Wednesday", workout: "Rest" },
      { day: "Thursday", workout: "Upper B (Hypertrophy)" },
      { day: "Friday", workout: "Lower B (Hinge)" },
      { day: "Saturday", workout: "Rest" },
      { day: "Sunday", workout: "Rest" },
    ],
    trainingDays: [
      {
        name: "Day 1",
        focus: "Upper A (Strength Focus)",
        exercises: [
          { name: "Machine Chest Press", imagePlaceholder: "Machine Chest Press", sets: "2 warm-up + 3", reps: "6-8", rest: "2-3 min", tempo: "2-0-1-0", notes: "Machine for stability" },
          { name: "Chest-Supported Row", imagePlaceholder: "Chest-Supported Row", sets: "2 warm-up + 3", reps: "8-10", rest: "2 min", tempo: "2-1-1-0", notes: "Mid-back isolation" },
          { name: "Seated Dumbbell Overhead Press", imagePlaceholder: "Seated Dumbbell Overhead Press", sets: "2 warm-up + 3", reps: "8-10", rest: "2 min", tempo: "2-0-1-0", notes: "Shoulder strength" },
          { name: "Cable Lateral Raise", imagePlaceholder: "Cable Lateral Raise", sets: "3", reps: "12-15", rest: "60 sec", tempo: "2-1-1-0", notes: "Constant tension" },
          { name: "Bayesian Cable Curl", imagePlaceholder: "Bayesian Cable Curl", sets: "3", reps: "10-12", rest: "60 sec", tempo: "3-0-1-0", notes: "Long head stretch" },
          { name: "Overhead Cable Tricep Extension", imagePlaceholder: "Overhead Cable Tricep Extension", sets: "3", reps: "10-12", rest: "60 sec", tempo: "2-1-1-0", notes: "Long head tricep" },
        ],
      },
    ],
    progression: [
      "Track RIR on every set — target RIR 1-3",
      "Add weight when completing all sets at RIR 1 or less",
      "Use a training log for weight, reps, and RIR",
    ],
    deload: "Every 6-8 weeks, reduce volume by 40-50%",
    recovery: [
      "Sleep 7-9 hours",
      "1.6-2.2g protein per kg bodyweight",
      "Consider creatine monohydrate (5g daily)",
    ],
    image: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800",
    tags: ["Science-Based", "RIR Tracking", "Evidence-Based"],
  },
];