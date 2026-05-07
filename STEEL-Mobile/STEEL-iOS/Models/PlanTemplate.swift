import Foundation

// MARK: - Plan Template Model
struct PlanTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let goalType: GoalType?
    let environment: Environment?
    let difficulty: ExerciseDifficulty?
    let durationWeeks: Int?
    let structure: [String: Any]?
    let popularity: Int?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case goalType = "goalType"
        case environment, difficulty
        case durationWeeks = "durationWeeks"
        case structure, popularity
        case created, updated
    }
    
    init(id: String, title: String, description: String? = nil, goalType: GoalType? = nil, environment: Environment? = nil, difficulty: ExerciseDifficulty? = nil, durationWeeks: Int? = nil, structure: [String: Any]? = nil, popularity: Int? = nil, created: Date, updated: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.goalType = goalType
        self.environment = environment
        self.difficulty = difficulty
        self.durationWeeks = durationWeeks
        self.structure = structure
        self.popularity = popularity
        self.created = created
        self.updated = updated
    }
}