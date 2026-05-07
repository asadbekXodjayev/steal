import Foundation

// MARK: - Exercise Translation Model
struct ExerciseTranslation: Codable, Identifiable {
    let id: String
    let exercise: String
    let locale: String
    let name: String
    let instructions: String?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, exercise, locale, name, instructions
        case created, updated
    }
    
    init(id: String, exercise: String, locale: String, name: String, instructions: String? = nil, created: Date, updated: Date) {
        self.id = id
        self.exercise = exercise
        self.locale = locale
        self.name = name
        self.instructions = instructions
        self.created = created
        self.updated = updated
    }
}