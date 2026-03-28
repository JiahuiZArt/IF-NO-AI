import Foundation
import FamilyControls

final class PersistenceService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let cityState = "cityState"
        static let streak = "streak"
        static let lastSuccessDate = "lastSuccessDate"
        static let records = "records"
        static let selectedDuration = "selectedDuration"
        static let failOnBackground = "failOnBackground"
        static let selectedApps = "selectedApps"
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

    func saveRecords(_ records: [Record]) {
        save(records, forKey: Keys.records)
    }

    func loadRecords() -> [Record] {
        load(type: [Record].self, forKey: Keys.records) ?? []
    }

    func saveSelectedDuration(_ duration: Int) {
        defaults.set(duration, forKey: Keys.selectedDuration)
    }

    func loadSelectedDuration() -> Int {
        let value = defaults.integer(forKey: Keys.selectedDuration)
        return [30, 60, 120].contains(value) ? value : 30
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
