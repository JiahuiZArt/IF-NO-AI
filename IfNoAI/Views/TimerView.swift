import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("专注中")
                .font(.title.bold())

            FocusGrowthView(
                progress: viewModel.sessionProgress,
                isWithered: false,
                isIdlePreview: false
            )
            .animation(.easeInOut(duration: 2.25), value: viewModel.sessionProgress)

            Text(timeString(from: viewModel.remainingSeconds))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("文明正沿时间轴演进，不要离开")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("放弃", role: .destructive) {
                viewModel.failSession()
            }
        }
        .padding()
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let sec = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, sec)
    }
}
