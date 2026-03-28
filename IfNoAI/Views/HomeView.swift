import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    var onStart: () -> Void
    var onSettings: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("如果没有AI")
                .font(.largeTitle.bold())

            CityBlocksView(level: viewModel.cityState.level, isFailed: false)
                .frame(height: 150)

            VStack(spacing: 8) {
                Text("当前城市：\(viewModel.cityState.level.title)")
                    .foregroundStyle(.secondary)
                Text("连续天数：\(viewModel.streak)")
                    .font(.title2.weight(.semibold))
                Text("成长进度：\(viewModel.cityState.progress)")
                    .foregroundStyle(.secondary)
            }

            Button("开始专注", action: onStart)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Button("设置", action: onSettings)
                .buttonStyle(.bordered)

            if !viewModel.records.isEmpty {
                List(viewModel.records.prefix(5)) { record in
                    HStack {
                        Text(record.date, style: .date)
                        Spacer()
                        Text("\(record.durationMinutes) 分钟")
                        Image(systemName: record.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(record.isSuccess ? .green : .red)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight: 240)
            }
        }
        .padding()
    }
}
