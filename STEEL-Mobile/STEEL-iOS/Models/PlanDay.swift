import Foundation

// MARK: - Plan Day Model
struct PlanDay: Codable, Identifiable {
    let id: String
    let plan: String
    let week: Int
    let dayOfWeek: Int
    let label: String?
    let focus: [String: Any]?
    let warmup: [String: Any]?
    let cooldown: [String: Any]?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, plan, week
        case dayOfWeek = "dayOfWeek"
        case label, focus, warmup, cooldown
        case created, updated
    }
    
    init(id: String, plan: String, week: Int, dayOfWeek: Int, label: String? = nil, focus: [String: Any]? = nil, warmup: [String: Any]? = nil, cooldown: [String: Any]? = nil, created: Date, updated: Date) {
        self.id = id
        self.plan = plan
        self.week = week
        self.dayOfWeek = dayOfWeek
        self.label = label
        self.focus = focus
        self.warmup = warmup
        self.cooldown = cooldown
        self.created = created
        self.updated = updated
    }
}