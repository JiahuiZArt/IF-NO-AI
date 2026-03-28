import SwiftUI

/// 首帧轻量：无 Canvas / TimelineView，缩短可感知的「白屏」
struct SplashLoadingView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 28) {
                Text("如果没有AI")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 3)
                        .frame(width: 52, height: 52)
                    Circle()
                        .trim(from: 0, to: 0.32)
                        .stroke(
                            AngularGradient(colors: [.cyan, .cyan.opacity(0.2)], center: .center),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(pulse ? 360 : 0))
                }
                Text("正在就绪…")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

/// 首次（或升级后）简短概念页；不加载主界面重视图
struct ConceptIntroView: View {
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.black, Color(red: 0.04, green: 0.08, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                Spacer(minLength: 24)
                Text("用一段时间")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("暂时挡住 AI 应用。专注走完这一程，画面里会从荒原慢慢走到城市文明；若中途放弃，就像被小行星撞击 —— 这一轮清零。")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineSpacing(6)
                VStack(alignment: .leading, spacing: 14) {
                    introRow(icon: "hourglass", text: "自选时长，系统级屏蔽你选的 App")
                    introRow(icon: "chart.line.uptrend.xyaxis", text: "进度只在这一轮计时里生长，简单又直观")
                    introRow(icon: "leaf.circle", text: "记录在右上角「足迹」里随时查看")
                }
                .padding(.top, 8)
                Spacer()
                Button {
                    onFinish()
                } label: {
                    Text("进入")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
        }
    }

    private func introRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.cyan.opacity(0.9))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
        }
    }
}
