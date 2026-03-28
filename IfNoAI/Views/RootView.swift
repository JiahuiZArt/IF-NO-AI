import SwiftUI

private enum BootPhase: Equatable {
    case splash
    case concept
    case main
}

struct RootView: View {
    @AppStorage("ifnoai.hasSeenConceptIntro") private var hasSeenConceptIntro = false
    @State private var bootPhase: BootPhase = .splash

    @StateObject private var viewModel = AppViewModel()
    @State private var path: [AppRoute] = []
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch bootPhase {
            case .splash:
                SplashLoadingView()
                    .task { await runSplashGate() }
            case .concept:
                ConceptIntroView {
                    hasSeenConceptIntro = true
                    withAnimation(.easeOut(duration: 0.25)) {
                        bootPhase = .main
                    }
                }
            case .main:
                mainStack
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { newPhase in
            guard bootPhase == .main else { return }
            viewModel.handleScenePhase(newPhase)
        }
        .alert("提示", isPresented: Binding(get: { viewModel.alertMessage != nil }, set: { if !$0 { viewModel.alertMessage = nil } }), actions: {
            Button("好的") { viewModel.alertMessage = nil }
        }, message: {
            Text(viewModel.alertMessage ?? "")
        })
    }

    private func runSplashGate() async {
        // 极短占位：让首屏先绘出轻量视图，再进入主界面（重型 Canvas 延后构建）
        try? await Task.sleep(nanoseconds: 320_000_000)
        await MainActor.run {
            if hasSeenConceptIntro {
                bootPhase = .main
            } else {
                bootPhase = .concept
            }
        }
    }

    private var mainStack: some View {
        NavigationStack(path: $path) {
            HomeView(
                viewModel: viewModel,
                onStart: { path.append(.start) }
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
                    SuccessView(record: viewModel.records.first, streak: viewModel.streak) {
                        viewModel.resetToIdle()
                        path = []
                    }
                case .failed:
                    FailView(record: viewModel.records.first) {
                        viewModel.resetToIdle()
                        path = []
                    }
                }
            }
        }
    }
}

enum AppRoute: Hashable {
    case start
    case timer
    case success
    case failed
}
