import Foundation

enum CityLevel: Int, Codable, CaseIterable {
    case wasteland = 0
    case town = 1
    case city = 2

    var title: String {
        switch self {
        case .wasteland: return "荒地"
        case .town: return "小镇"
        case .city: return "城市"
        }
    }
}

struct CityState: Codable {
    var level: CityLevel
    var progress: Int

    static let upgradeThresholds: [CityLevel: Int] = [
        .wasteland: 0,
        .town: 3,
        .city: 7
    ]

    static let initial = CityState(level: .wasteland, progress: 0)

    mutating func applySuccess() {
        progress += 1
        recalculateLevel()
    }

    mutating func applyFailure() {
        progress = max(0, progress - 2)
        recalculateLevel()
    }

    mutating func recalculateLevel() {
        if progress >= (Self.upgradeThresholds[.city] ?? 7) {
            level = .city
        } else if progress >= (Self.upgradeThresholds[.town] ?? 3) {
            level = .town
        } else {
            level = .wasteland
        }
    }
}
