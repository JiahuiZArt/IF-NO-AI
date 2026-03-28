import Foundation

struct FocusRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let plannedMinutes: Int
    let elapsedMinutes: Int
    let completed: Bool
    /// 结束瞬间的成长进度 0...1（成功为 1）
    let progressAtEnd: Double
    let achievementSummary: String

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date = .now,
        plannedMinutes: Int,
        elapsedMinutes: Int,
        completed: Bool,
        progressAtEnd: Double,
        achievementSummary: String
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.elapsedMinutes = elapsedMinutes
        self.completed = completed
        self.progressAtEnd = progressAtEnd
        self.achievementSummary = achievementSummary
    }
}

extension FocusRecord {
    static func makeAchievementSummary(
        completed: Bool,
        plannedMinutes: Int,
        elapsedMinutes: Int,
        progress: Double
    ) -> String {
        let era = CivilizationEra.era(for: progress)
        if completed {
            return "完整演进 · \(plannedMinutes) 分钟 · 抵达「\(era.title)」"
        }
        return "已专注 \(elapsedMinutes) 分钟 · 文明停在「\(era.title)」"
    }

    init(migratingLegacy id: UUID, date: Date, durationMinutes: Int, isSuccess: Bool) {
        self.id = id
        self.startedAt = date
        self.endedAt = date
        self.plannedMinutes = durationMinutes
        self.elapsedMinutes = isSuccess ? durationMinutes : 0
        self.completed = isSuccess
        self.progressAtEnd = isSuccess ? 1.0 : 0
        self.achievementSummary = isSuccess
            ? "完整演进 · \(durationMinutes) 分钟 · 抵达城市文明"
            : "未完成 · 历史记录已迁移"
    }
}
