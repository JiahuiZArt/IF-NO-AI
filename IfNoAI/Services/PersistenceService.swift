import Foundation
import FamilyControls

final class PersistenceService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let cityState = "cityState"
        static let streak = "streak"
        static let lastSuccessDate = "lastSuccessDate"
        static let recordsLegacy = "records"
        static let focusRecords = "focusRecords"
        static let selectedDuration = "selectedDuration"
        static let failOnBackground = "failOnBackground"
        static let selectedApps = "selectedApps"
    }

    private struct LegacyRecord: Codable {
        let id: UUID
        let date: Date
        let durationMinutes: Int
        let isSuccess: Bool
    }

    func saveCityState(_ state: CityState) {
        save(state, forKey: Keys.cityState)
    }

    func loadCityState() -> CityState {
        load(type: CityState.self, forKey: Keys.cityState) ?? .initial
    }

    func saveStreak(_ streak: Int) {
        defaults.set(streak, forKey: Keys.streak)
    }

    func loadStreak() -> Int {
        defaults.integer(forKey: Keys.streak)
    }

    func saveLastSuccessDate(_ date: Date?) {
        defaults.set(date, forKey: Keys.lastSuccessDate)
    }

    func loadLastSuccessDate() -> Date? {
        defaults.object(forKey: Keys.lastSuccessDate) as? Date
    }

    func saveRecords(_ records: [FocusRecord]) {
        save(records, forKey: Keys.focusRecords)
    }

    func loadRecords() -> [FocusRecord] {
        if let data = defaults.data(forKey: Keys.focusRecords),
           let decoded = try? JSONDecoder().decode([FocusRecord].self, from: data) {
            return decoded
        }
        if let data = defaults.data(forKey: Keys.recordsLegacy),
           let legacy = try? JSONDecoder().decode([LegacyRecord].self, from: data) {
            let migrated = legacy.map {
                FocusRecord(migratingLegacy: $0.id, date: $0.date, durationMinutes: $0.durationMinutes, isSuccess: $0.isSuccess)
            }
            saveRecords(migrated)
            defaults.removeObject(forKey: Keys.recordsLegacy)
            return migrated
        }
        return []
    }

    func saveSelectedDuration(_ duration: Int) {
        defaults.set(duration, forKey: Keys.selectedDuration)
    }

    func loadSelectedDuration() -> Int {
        let v = defaults.integer(forKey: Keys.selectedDuration)
        if v == 0 { return 30 }
        return min(180, max(5, v))
    }

    func saveFailOnBackground(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.failOnBackground)
    }

    func loadFailOnBackground() -> Bool {
        defaults.object(forKey: Keys.failOnBackground) as? Bool ?? true
    }

    func saveSelectedApps(_ selection: FamilyActivitySelection) {
        save(selection, forKey: Keys.selectedApps)
    }

    func loadSelectedApps() -> FamilyActivitySelection {
        load(type: FamilyActivitySelection.self, forKey: Keys.selectedApps) ?? FamilyActivitySelection()
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func load<T: Decodable>(type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
