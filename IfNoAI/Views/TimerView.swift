import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 28) {
            Text("专注中")
                .font(.title.bold())

            CityBlocksView(level: viewModel.cityState.level, isFailed: false)
                .frame(height: 150)

            Text(timeString(from: viewModel.remainingSeconds))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("不要离开这个世界")
                .foregroundStyle(.secondary)

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
