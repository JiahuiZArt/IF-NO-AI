import Foundation
import FamilyControls
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var cityState: CityState
    @Published var streak: Int
    @Published var selectedDuration: Int
    @Published var selectedApps: FamilyActivitySelection
    @Published var failOnBackground: Bool
    @Published var currentSession: FocusSession?
    @Published var status: FocusStatus = .idle
    @Published var remainingSeconds: Int = 0
    /// 本轮计划总秒数（用于成长进度条）
    private(set) var plannedTotalSeconds: Int = 0
    @Published var records: [FocusRecord]
    @Published var showPicker = false
    @Published var alertMessage: String?

    private var timerTask: Task<Void, Never>?
    private var lastSuccessDate: Date?

    private let persistence: PersistenceService
    private let screenTimeService: ScreenTimeService

    init(
        persistence: PersistenceService = PersistenceService(),
        screenTimeService: ScreenTimeService? = nil
    ) {
        self.persistence = persistence
        self.screenTimeService = screenTimeService ?? ScreenTimeService()

        self.cityState = persistence.loadCityState()
        self.streak = persistence.loadStreak()
        self.lastSuccessDate = persistence.loadLastSuccessDate()
        self.records = persistence.loadRecords()
        self.selectedDuration = persistence.loadSelectedDuration()
        self.failOnBackground = persistence.loadFailOnBackground()
        self.selectedApps = persistence.loadSelectedApps()
    }

    deinit {
        timerTask?.cancel()
    }

    /// 当前专注进度 0...1（非 running 为 0）
    var sessionProgress: Double {
        guard status == .running, plannedTotalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(plannedTotalSeconds)
    }

    func saveSettings() {
        selectedDuration = Self.clampMinutes(selectedDuration)
        persistence.saveSelectedDuration(selectedDuration)
        persistence.saveFailOnBackground(failOnBackground)
        persistence.saveSelectedApps(selectedApps)
    }

    private static func clampMinutes(_ m: Int) -> Int {
        min(180, max(5, m))
    }

    func requestScreenTimeAuthorization() {
        Task {
            do {
                try await screenTimeService.requestAuthorization()
            } catch {
                alertMessage = "请在系统设置中允许屏幕使用时间权限。"
            }
        }
    }

    func startFocus() {
        requestScreenTimeAuthorization()
        selectedDuration = Self.clampMinutes(selectedDuration)
        persistence.saveSelectedDuration(selectedDuration)

        status = .running
        plannedTotalSeconds = max(1, selectedDuration * 60)
        remainingSeconds = plannedTotalSeconds
        currentSession = FocusSession(durationMinutes: selectedDuration, status: .running)
        screenTimeService.applyRestrictions(using: selectedApps)

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && self.remainingSeconds > 0 && self.status == .running {
                try? await Task.sleep(for: .seconds(1))
                self.remainingSeconds -= 1
            }

            if self.status == .running && self.remainingSeconds <= 0 {
                self.finishSession(success: true)
            }
        }
    }

    func failSession() {
        guard status == .running else { return }
        finishSession(success: false)
    }

    func handleScenePhase(_ phase: ScenePhase) {
        guard failOnBackground else { return }
        if phase == .background || phase == .inactive {
            failSession()
        }
    }

    func resetToIdle() {
        status = .idle
        currentSession = nil
        remainingSeconds = 0
        plannedTotalSeconds = 0
    }

    private func finishSession(success: Bool) {
        timerTask?.cancel()
        screenTimeService.clearRestrictions()

        if success {
            status = .success
            cityState.applySuccess()
            updateStreakOnSuccess()
        } else {
            status = .failed
            cityState.applyFailure()
            streak = 0
        }

        if var session = currentSession {
            session.status = success ? .success : .failed
            currentSession = session

            let elapsedSeconds = max(0, plannedTotalSeconds - remainingSeconds)
            let elapsedMinutes = elapsedSeconds / 60
            let endProgress: Double = {
                if success { return 1 }
                guard plannedTotalSeconds > 0 else { return 0 }
                return 1.0 - Double(remainingSeconds) / Double(plannedTotalSeconds)
            }()
            let summary = FocusRecord.makeAchievementSummary(
                completed: success,
                plannedMinutes: session.durationMinutes,
                elapsedMinutes: elapsedMinutes,
                progress: endProgress
            )
            let record = FocusRecord(
                startedAt: session.startDate,
                plannedMinutes: session.durationMinutes,
                elapsedMinutes: elapsedMinutes,
                completed: success,
                progressAtEnd: endProgress,
                achievementSummary: summary
            )
            records.insert(record, at: 0)
            records = Array(records.prefix(100))
        }

        persistAll()
    }

    private func updateStreakOnSuccess() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastDate = lastSuccessDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                return
            }

            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak = 1
        }

        lastSuccessDate = today
        persistence.saveLastSuccessDate(today)
    }

    private func persistAll() {
        persistence.saveCityState(cityState)
        persistence.saveStreak(streak)
        persistence.saveRecords(records)
        persistence.saveSelectedDuration(selectedDuration)
        persistence.saveFailOnBackground(failOnBackground)
        persistence.saveSelectedApps(selectedApps)
        persistence.saveLastSuccessDate(lastSuccessDate)
    }
}
