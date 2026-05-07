import Foundation

// MARK: - Session Set Model
struct SessionSet: Codable, Identifiable {
    let id: String
    let session: String
    let exercise: String?
    let setNumber: Int?
    let reps: Int?
    let weight: Double?
    let rpe: Double?
    let completed: Bool
    let notes: String?
    let created: Date
    let updated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, session, exercise
        case setNumber = "setNumber"
        case reps, weight, rpe, completed, notes
        case created, updated
    }
    
    init(id: String, session: String, exercise: String? = nil, setNumber: Int? = nil, reps: Int? = nil, weight: Double? = nil, rpe: Double? = nil, completed: Bool = false, notes: String? = nil, created: Date, updated: Date) {
        self.id = id
        self.session = session
        self.exercise = exercise
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.completed = completed
        self.notes = notes
        self.created = created
        self.updated = updated
    }
}