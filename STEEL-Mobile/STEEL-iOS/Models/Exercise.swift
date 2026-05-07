import Foundation

// MARK: - Exercise Model
struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
    let muscleGroups: [String]?
    let equipment: [String]?
    let category: ExerciseCategory?
    let difficulty: ExerciseDifficulty?
    let instructions: String?
    let videoUrl: String?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case muscleGroups = "muscleGroups"
        case equipment
        case category, difficulty, instructions
        case videoUrl = "videoUrl"
        case created, updated
    }
    
    init(id: String, name: String, slug: String, muscleGroups: [String]? = nil, equipment: [String]? = nil, category: ExerciseCategory? = nil, difficulty: ExerciseDifficulty? = nil, instructions: String? = nil, videoUrl: String? = nil, created: Date, updated: Date) {
        self.id = id
        self.name = name
        self.slug = slug
        self.muscleGroups = muscleGroups
        self.equipment = equipment
        self.category = category
        self.difficulty = difficulty
        self.instructions = instructions
        self.videoUrl = videoUrl
        self.created = created
        self.updated = updated
    }
}

// MARK: - Exercise Category Enum
enum ExerciseCategory: String, Codable {
    case compound
    case isolation
    case cardio
    case mobility
    case warmup
    case cooldown
}

// MARK: - Exercise Difficulty Enum
enum ExerciseDifficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}