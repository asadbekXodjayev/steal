import Foundation

// MARK: - Plan Exercise Model
struct PlanExercise: Codable, Identifiable {
    let id: String
    let planDay: String
    let exercise: String?
    let name: String?
    let order: Int?
    let sets: Int?
    let repsMin: Int?
    let repsMax: Int?
    let rpeTarget: Double?
    let restSeconds: Int?
    let notes: String?
    let substitutions: [String: Any]?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case planDay = "planDay"
        case exercise, name, order, sets
        case repsMin = "repsMin"
        case repsMax = "repsMax"
        case rpeTarget = "rpeTarget"
        case restSeconds = "restSeconds"
        case notes, substitutions
        case created, updated
    }
    
    init(id: String, planDay: String, exercise: String? = nil, name: String? = nil, order: Int? = nil, sets: Int? = nil, repsMin: Int? = nil, repsMax: Int? = nil, rpeTarget: Double? = nil, restSeconds: Int? = nil, notes: String? = nil, substitutions: [String: Any]? = nil, created: Date, updated: Date) {
        self.id = id
        self.planDay = planDay
        self.exercise = exercise
        self.name = name
        self.order = order
        self.sets = sets
        self.repsMin = repsMin
        self.repsMax = repsMax
        self.rpeTarget = rpeTarget
        self.restSeconds = restSeconds
        self.notes = notes
        self.substitutions = substitutions
        self.created = created
        self.updated = updated
    }
}