import SwiftUI

struct SuccessView: View {
    let record: FocusRecord?
    let streak: Int
    var onBackHome: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            FocusGrowthView(progress: 1, isWithered: false, isIdlePreview: false)

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.cyan)

            Text("本轮文明演进完成")
                .font(.largeTitle.bold())

            if let record {
                Text(record.achievementSummary)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            Text("连续天数：\(streak)")
                .font(.title3.weight(.semibold))

            Button("返回首页", action: onBackHome)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer()
        }
        .padding()
    }
}
