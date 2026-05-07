import Foundation

// MARK: - Workout Plan Model
struct WorkoutPlan: Codable, Identifiable {
    let id: String
    let user: String
    let title: String
    let description: String?
    let source: PlanSource?
    let goalType: GoalType?
    let environment: Environment?
    let durationWeeks: Int?
    let currentWeek: Int?
    let status: PlanStatus?
    let therapyNotes: [String: Any]?
    let progressionRules: [String: Any]?
    let aiPromptSnapshot: [String: Any]?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user, title, description, source
        case goalType = "goalType"
        case environment
        case durationWeeks = "durationWeeks"
        case currentWeek = "currentWeek"
        case status
        case therapyNotes = "therapyNotes"
        case progressionRules = "progressionRules"
        case aiPromptSnapshot = "aiPromptSnapshot"
        case created, updated
    }
    
    init(id: String, user: String, title: String, description: String? = nil, source: PlanSource? = nil, goalType: GoalType? = nil, environment: Environment? = nil, durationWeeks: Int? = nil, currentWeek: Int? = nil, status: PlanStatus? = nil, created: Date, updated: Date) {
        self.id = id
        self.user = user
        self.title = title
        self.description = description
        self.source = source
        self.goalType = goalType
        self.environment = environment
        self.durationWeeks = durationWeeks
        self.currentWeek = currentWeek
        self.status = status
        self.created = created
        self.updated = updated
    }
}

// MARK: - Plan Source Enum
enum PlanSource: String, Codable {
    case ai_generated = "ai_generated"
    case template
    case custom
}

// MARK: - Plan Status Enum
enum PlanStatus: String, Codable {
    case active
    case completed
    case paused
    case archived
}