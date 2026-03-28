import SwiftUI

struct FailView: View {
    var onBackHome: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            CityBlocksView(level: .wasteland, isFailed: true)
                .frame(height: 150)

            Text("挑战失败")
                .font(.largeTitle.bold())

            Text("你离开了专注状态，城市陷入灰暗。")
                .foregroundStyle(.secondary)

            Button("重新开始", action: onBackHome)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}
