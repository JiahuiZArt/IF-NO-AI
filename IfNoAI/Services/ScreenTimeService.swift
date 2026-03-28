import Foundation
import FamilyControls
import ManagedSettings

@MainActor
final class ScreenTimeService: ObservableObject {
    private let store = ManagedSettingsStore(named: .init("IfNoAI.Focus"))

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    func applyRestrictions(using selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    }

    func clearRestrictions() {
        store.clearAllSettings()
    }
}
