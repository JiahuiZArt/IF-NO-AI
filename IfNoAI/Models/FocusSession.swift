import Foundation

enum FocusStatus: String, Codable {
    case idle
    case running
    case success
    case failed
}

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let durationMinutes: Int
    var status: FocusStatus

    init(id: UUID = UUID(), startDate: Date = .now, durationMinutes: Int, status: FocusStatus) {
        self.id = id
        self.startDate = startDate
        self.durationMinutes = durationMinutes
        self.status = status
    }
}
