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

    var sessionIcon: String {
        switch self {
        case .wasteland: return "leaf"
        case .town: return "tree"
        case .city: return "building.2"
        }
    }

    /// 兼容成就文案：将演进阶段粗略映射回三地貌
    static func fromSessionProgress(_ p: Double) -> CityLevel {
        switch CivilizationEra.era(for: p) {
        case .barren, .lifeBloom, .wildBeasts: return .wasteland
        case .firekeeper, .tribe, .settlement: return .town
        case .protoCity, .metropolis: return .city
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

    /// 长期养成：距离下一地貌还要几次成功专注
    var landMilestoneHint: String {
        let townAt = Self.upgradeThresholds[.town] ?? 3
        let cityAt = Self.upgradeThresholds[.city] ?? 7
        switch level {
        case .wasteland:
            let n = max(0, townAt - progress)
            return n == 0 ? "即将升入小镇" : "再完整成长 \(n) 次 → 小镇"
        case .town:
            let n = max(0, cityAt - progress)
            return n == 0 ? "即将升入城市" : "再完整成长 \(n) 次 → 城市"
        case .city:
            return "累计完整成长 \(progress) 次"
        }
    }
}
