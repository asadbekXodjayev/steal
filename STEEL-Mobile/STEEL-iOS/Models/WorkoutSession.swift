import Foundation

// MARK: - Workout Session Model
struct WorkoutSession: Codable, Identifiable {
    let id: String
    let user: String
    let planDay: String?
    let plan: String?
    let startedAt: Date?
    let completedAt: Date?
    let status: SessionStatus
    let mood: SessionMood?
    let energyLevel: Int?
    let sessionNotes: String?
    let therapyReflection: String?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user
        case planDay = "planDay"
        case plan
        case startedAt = "startedAt"
        case completedAt = "completedAt"
        case status, mood
        case energyLevel = "energyLevel"
        case sessionNotes = "sessionNotes"
        case therapyReflection = "therapyReflection"
        case created, updated
    }
    
    init(id: String, user: String, planDay: String? = nil, plan: String? = nil, startedAt: Date? = nil, completedAt: Date? = nil, status: SessionStatus = .in_progress, mood: SessionMood? = nil, energyLevel: Int? = nil, sessionNotes: String? = nil, therapyReflection: String? = nil, created: Date, updated: Date) {
        self.id = id
        self.user = user
        self.planDay = planDay
        self.plan = plan
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.status = status
        self.mood = mood
        self.energyLevel = energyLevel
        self.sessionNotes = sessionNotes
        self.therapyReflection = therapyReflection
        self.created = created
        self.updated = updated
    }
}

// MARK: - Session Status Enum
enum SessionStatus: String, Codable {
    case in_progress = "in_progress"
    case completed
    case skipped
}

// MARK: - Session Mood Enum
enum SessionMood: String, Codable {
    case great
    case good
    case okay
    case rough
    case terrible
}