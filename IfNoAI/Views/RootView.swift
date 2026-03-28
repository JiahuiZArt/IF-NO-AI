import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var path: [AppRoute] = []
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                viewModel: viewModel,
                onStart: { path.append(.start) },
                onSettings: { path.append(.settings) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .start:
                    StartView {
                        viewModel.startFocus()
                        path.append(.timer)
                    }
                case .timer:
                    TimerView(viewModel: viewModel)
                        .onChange(of: viewModel.status) { status in
                            if status == .success {
                                path.append(.success)
                            } else if status == .failed {
                                path.append(.failed)
                            }
                        }
                case .success:
                    SuccessView(streak: viewModel.streak) {
                        viewModel.resetToIdle()
                        path = []
                    }
                case .failed:
                    FailView {
                        viewModel.resetToIdle()
                        path = []
                    }
                case .settings:
                    SettingsView(viewModel: viewModel)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { newPhase in
            viewModel.handleScenePhase(newPhase)
        }
        .alert("提示", isPresented: Binding(get: { viewModel.alertMessage != nil }, set: { if !$0 { viewModel.alertMessage = nil } }), actions: {
            Button("好的") { viewModel.alertMessage = nil }
        }, message: {
            Text(viewModel.alertMessage ?? "")
        })
    }
}

enum AppRoute: Hashable {
    case start
    case timer
    case success
    case failed
    case settings
}
