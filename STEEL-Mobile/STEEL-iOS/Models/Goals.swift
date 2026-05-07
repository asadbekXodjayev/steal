import Foundation

// MARK: - Goal Model
struct Goal: Codable, Identifiable {
    let id: String
    let user: String
    let type: GoalType?
    let environment: Environment?
    let equipment: [String]?
    let daysPerWeek: Int?
    let sessionMinutes: Int?
    let priority: GoalPriority?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user, type, environment, equipment
        case daysPerWeek = "daysPerWeek"
        case sessionMinutes = "sessionMinutes"
        case priority
        case created, updated
    }
    
    init(id: String, user: String, type: GoalType? = nil, environment: Environment? = nil, equipment: [String]? = nil, daysPerWeek: Int? = nil, sessionMinutes: Int? = nil, priority: GoalPriority? = nil, created: Date, updated: Date) {
        self.id = id
        self.user = user
        self.type = type
        self.environment = environment
        self.equipment = equipment
        self.daysPerWeek = daysPerWeek
        self.sessionMinutes = sessionMinutes
        self.priority = priority
        self.created = created
        self.updated = updated
    }
}

// MARK: - Goal Type Enum
enum GoalType: String, Codable {
    case muscle_building = "muscle_building"
    case strength
    case fat_loss = "fat_loss"
    case endurance
    case rehabilitation
    case general_fitness = "general_fitness"
}

// MARK: - Environment Enum
enum Environment: String, Codable {
    case gym
    case home
    case outdoor
    case mixed
}

// MARK: - Goal Priority Enum
enum GoalPriority: String, Codable {
    case primary
    case secondary
}