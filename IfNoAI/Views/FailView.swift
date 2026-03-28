import SwiftUI

struct FailView: View {
    let record: FocusRecord?
    var onBackHome: () -> Void

    @State private var showAftermath = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            FocusGrowthView(
                progress: record?.progressAtEnd ?? 0,
                isWithered: true,
                isIdlePreview: false
            )
            .opacity(0.22)
            .blur(radius: 10)
            .allowsHitTesting(false)

            AsteroidImpactVisual()
                .allowsHitTesting(false)

            VStack(spacing: 20) {
                Spacer(minLength: 12)

                if showAftermath {
                    VStack(spacing: 16) {
                        Text("小行星撞击")
                            .font(.largeTitle.bold())
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
                            )

                        Text("这一瞬间，尚未完成的文明全部归零。")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        if let record {
                            Text(record.achievementSummary)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal)
                        } else {
                            Text("下次再试，把时间轴推得更远一些。")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }

                        Button("返回荒原", action: onBackHome)
                            .buttonStyle(.borderedProminent)
                            .tint(.orange.opacity(0.85))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
                withAnimation(.easeOut(duration: 0.45)) {
                    showAftermath = true
                }
            }
        }
    }
}
