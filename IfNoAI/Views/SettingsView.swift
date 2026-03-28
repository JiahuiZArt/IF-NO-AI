import SwiftUI
import FamilyControls

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Section("专注时长") {
                Picker("时长", selection: $viewModel.selectedDuration) {
                    Text("30 分钟").tag(30)
                    Text("60 分钟").tag(60)
                    Text("120 分钟").tag(120)
                }
                .pickerStyle(.segmented)
            }

            Section("违规判定") {
                Toggle("切后台即失败", isOn: $viewModel.failOnBackground)
                    .tint(.cyan)
            }

            Section("限制 App") {
                Button("选择要限制的应用") {
                    viewModel.showPicker = true
                }
                .familyActivityPicker(isPresented: $viewModel.showPicker, selection: $viewModel.selectedApps)

                Text("已选择 App 数：\(viewModel.selectedApps.applicationTokens.count)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            Section {
                Button("保存设置") {
                    viewModel.saveSettings()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("设置")
    }
}
