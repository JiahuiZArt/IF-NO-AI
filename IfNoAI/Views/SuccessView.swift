import SwiftUI

struct SuccessView: View {
    let streak: Int
    var onBackHome: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.cyan)

            Text("城市升级")
                .font(.largeTitle.bold())

            Text("连续天数 +1")
                .foregroundStyle(.secondary)

            Text("当前 streak：\(streak)")
                .font(.title3.weight(.semibold))

            Button("返回首页", action: onBackHome)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer()
        }
        .padding()
    }
}
