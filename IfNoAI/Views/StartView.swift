import SwiftUI

struct StartView: View {
    var onStartPressed: () -> Void

    var body: some View {
        VStack(spacing: 36) {
            Spacer()
            Text("接下来你将独立思考")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("长按开始")
                .foregroundStyle(.white.opacity(0.7))

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 160, height: 160)
                .overlay(
                    Text("长按")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )
                .onLongPressGesture(minimumDuration: 1.2, perform: onStartPressed)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
