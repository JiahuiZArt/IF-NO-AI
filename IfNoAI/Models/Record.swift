import Foundation

struct Record: Identifiable, Codable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
    let isSuccess: Bool

    init(id: UUID = UUID(), date: Date = .now, durationMinutes: Int, isSuccess: Bool) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.isSuccess = isSuccess
    }
}
