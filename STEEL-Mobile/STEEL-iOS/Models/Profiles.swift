import Foundation

// MARK: - Profile Model
struct Profile: Codable, Identifiable {
    let id: String
    let user: String
    let age: Int?
    let height: Int?          // cm
    let weight: Double?       // kg
    let gender: Gender?
    let fitnessLevel: FitnessLevel?
    let limitations: [String]?
    let injuryHistory: String?
    let onboardingComplete: Bool
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user, age, height, weight, gender
        case fitnessLevel = "fitnessLevel"
        case limitations
        case injuryHistory = "injuryHistory"
        case onboardingComplete = "onboardingComplete"
        case created, updated
    }
    
    init(id: String, user: String, age: Int? = nil, height: Int? = nil, weight: Double? = nil, gender: Gender? = nil, fitnessLevel: FitnessLevel? = nil, limitations: [String]? = nil, injuryHistory: String? = nil, onboardingComplete: Bool = false, created: Date, updated: Date) {
        self.id = id
        self.user = user
        self.age = age
        self.height = height
        self.weight = weight
        self.gender = gender
        self.fitnessLevel = fitnessLevel
        self.limitations = limitations
        self.injuryHistory = injuryHistory
        self.onboardingComplete = onboardingComplete
        self.created = created
        self.updated = updated
    }
}

// MARK: - Gender Enum
enum Gender: String, Codable {
    case male
    case female
    case other
    case prefer_not_to_say = "prefer_not_to_say"
}

// MARK: - Fitness Level Enum
enum FitnessLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
}