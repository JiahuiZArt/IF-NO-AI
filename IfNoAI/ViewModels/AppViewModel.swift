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
    @Published var records: [Record]
    @Published var showPicker = false
    @Published var alertMessage: String?

    private var timerTask: Task<Void, Never>?
    private var lastSuccessDate: Date?

    private let persistence: PersistenceService
    private let screenTimeService: ScreenTimeService

    init(
        persistence: PersistenceService = PersistenceService(),
        screenTimeService: ScreenTimeService = ScreenTimeService()
    ) {
        self.persistence = persistence
        self.screenTimeService = screenTimeService

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

    func saveSettings() {
        persistence.saveSelectedDuration(selectedDuration)
        persistence.saveFailOnBackground(failOnBackground)
        persistence.saveSelectedApps(selectedApps)
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
        status = .running
        remainingSeconds = selectedDuration * 60
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
            records.insert(Record(durationMinutes: session.durationMinutes, isSuccess: success), at: 0)
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
