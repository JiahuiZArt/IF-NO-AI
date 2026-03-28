import SwiftUI

struct CityBlocksView: View {
    let level: CityLevel
    let isFailed: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 130)
                .cornerRadius(14)

            HStack(alignment: .bottom, spacing: 8) {
                block(height: 35)
                if level != .wasteland { block(height: 60) }
                if level == .city { block(height: 95) }
                block(height: level == .city ? 70 : 28)
            }
            .padding(.bottom, 20)
        }
        .foregroundStyle(isFailed ? Color.gray : Color.cyan)
        .animation(.easeInOut(duration: 0.35), value: level)
        .animation(.easeInOut(duration: 0.35), value: isFailed)
    }

    private func block(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill((isFailed ? Color.gray : Color.cyan).opacity(0.85))
            .frame(width: 30, height: height)
    }
}
