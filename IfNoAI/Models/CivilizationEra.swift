import Foundation

/// 单次专注内：从死寂荒原一路演进到城市文明（与时间进度 0…1 同步）
enum CivilizationEra: Int, CaseIterable, Identifiable {
    case barren = 0       // 死寂荒原
    case lifeBloom = 1   // 生命萌发
    case wildBeasts = 2  // 原野生灵
    case firekeeper = 3  // 原始人与火
    case tribe = 4       // 部落时代
    case settlement = 5  // 农耕聚落
    case protoCity = 6   // 城镇兴起
    case metropolis = 7  // 城市文明

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .barren: return "荒原"
        case .lifeBloom: return "生命"
        case .wildBeasts: return "生灵"
        case .firekeeper: return "原始人"
        case .tribe: return "部落"
        case .settlement: return "聚落"
        case .protoCity: return "城镇"
        case .metropolis: return "城市文明"
        }
    }

    /// 演进旁白（文明史口吻）
    var narrativeLine: String {
        switch self {
        case .barren: return "亿万年风砂 · 大地还没有名字"
        case .lifeBloom: return "海里与土里 · 第一次心跳微不可见"
        case .wildBeasts: return "四肢掠过草丛 · 世界开始喧闹"
        case .firekeeper: return "火星被捧在手心 · 黑夜让位于围坐"
        case .tribe: return "血缘与誓言拧成绳 · 人群有了方向"
        case .settlement: return "种子返回土地 · 屋檐连成巷陌"
        case .protoCity: return "石与砖垒起野心 · 广场上有新的语言"
        case .metropolis: return "灯火如河 · 一座文明终于自称是「我们」"
        }
    }

    var symbolName: String {
        switch self {
        case .barren: return "moon.stars.fill"
        case .lifeBloom: return "leaf.circle.fill"
        case .wildBeasts: return "pawprint.fill"
        case .firekeeper: return "flame.fill"
        case .tribe: return "person.3.fill"
        case .settlement: return "house.and.flag.fill"
        case .protoCity: return "building.columns.fill"
        case .metropolis: return "building.2.fill"
        }
    }

    static func era(for progress: Double) -> CivilizationEra {
        let x = min(1, max(0, progress))
        let n = Double(allCases.count)
        let idx = max(0, min(allCases.count - 1, Int(floor(x * n - 1e-9))))
        return CivilizationEra(rawValue: idx) ?? .barren
    }

    static var evolutionTitlesJoined: String {
        allCases.map(\.title).joined(separator: " → ")
    }
}
