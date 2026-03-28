import SwiftUI

/// 失败瞬间：小行星轨迹、闪光、冲击波与暗幕（文明清零的意象）
struct AsteroidImpactVisual: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var strike: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w * 0.52
            let cy = h * 0.34

            ZStack {
                Color.orange.opacity(0.08 * Double(strike))
                    .ignoresSafeArea()

                ForEach(0..<4, id: \.self) { ring in
                    let lag = CGFloat(ring) * 0.07
                    let p = max(0, strike - lag)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.75), Color.red.opacity(0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 4 - CGFloat(ring)
                        )
                        .frame(width: 28 + p * w * 0.95, height: 28 + p * w * 0.95)
                        .opacity(Double(1 - p * 0.85))
                        .position(x: cx, y: cy)
                }

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.gray.opacity(0.85),
                                Color.brown.opacity(0.9),
                                Color.black.opacity(0.92)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 62 - strike * 10, height: 26)
                    .rotationEffect(.degrees(-38))
                    .offset(
                        x: -w * 0.48 + strike * w * 0.92,
                        y: -h * 0.38 + strike * h * 0.78
                    )
                    .shadow(color: .orange.opacity(0.5), radius: strike * 8)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.yellow.opacity(0.95),
                                Color.orange.opacity(0.75),
                                Color.red.opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.45 * strike
                        )
                    )
                    .frame(width: w * 0.7 * strike, height: w * 0.7 * strike)
                    .opacity(Double(min(1, strike * 1.4)))
                    .position(x: cx, y: cy)
                    .blendMode(.plusLighter)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.55 * Double(strike)), Color.black.opacity(0.92 * Double(strike))],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            if reduceMotion {
                strike = 1
            } else {
                withAnimation(.easeIn(duration: 0.58)) {
                    strike = 1
                }
            }
        }
    }
}
