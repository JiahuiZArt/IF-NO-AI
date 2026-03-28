import SwiftUI
import FamilyControls

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    var onStart: () -> Void

    @State private var customMinutesText = ""
    @State private var showCustomDurationSheet = false
    @State private var showForestSheet = false

    private let presetRing = [25, 30, 45, 60, 90, 120, 180]
    private let quickDots = [30, 45, 60, 90, 120]

    private var totalShieldCount: Int {
        viewModel.selectedApps.applicationTokens.count + viewModel.selectedApps.categoryTokens.count
    }

    private var appTileSubtitle: String {
        let apps = viewModel.selectedApps.applicationTokens.count
        let cats = viewModel.selectedApps.categoryTokens.count
        if apps == 0 && cats == 0 {
            return "点一下，挑要挡住的 AI"
        }
        var parts: [String] = []
        if apps > 0 { parts.append("\(apps) 个 App") }
        if cats > 0 { parts.append("\(cats) 类") }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerStrip

                FocusGrowthView(progress: 0, isWithered: false, isIdlePreview: true, compact: true)

                Text("本轮 \(viewModel.selectedDuration) 分钟 · \(CivilizationEra.evolutionTitlesJoined)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 4)
                    .padding(.horizontal, 4)

                HStack(alignment: .top, spacing: 10) {
                    playfulDurationCard
                    appShieldCard
                }
                .padding(.top, 10)

                backgroundRuleBubble
                    .padding(.top, 10)

                Spacer(minLength: 6)

                startButton
                    .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.001))
        .familyActivityPicker(isPresented: $viewModel.showPicker, selection: $viewModel.selectedApps)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showForestSheet = true
                } label: {
                    Image(systemName: "leaf.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("文明足迹")
            }
        }
        .sheet(isPresented: $showCustomDurationSheet) {
            customDurationSheet
        }
        .sheet(isPresented: $showForestSheet) {
            FocusForestSheet(viewModel: viewModel)
        }
        .onAppear {
            customMinutesText = "\(viewModel.selectedDuration)"
        }
        .onChange(of: viewModel.failOnBackground) { _ in viewModel.saveSettings() }
        .onChange(of: viewModel.showPicker) { isPresented in
            if !isPresented { viewModel.saveSettings() }
        }
    }

    private var headerStrip: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("如果没有AI")
                    .font(.title2.bold())
                HStack(spacing: 6) {
                    Text(viewModel.cityState.level.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                    Text("连胜 \(viewModel.streak)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.cyan)
                }
                Text(viewModel.cityState.landMilestoneHint)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 6)
    }

    private var playfulDurationCard: some View {
        VStack(spacing: 8) {
            Text("时长")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                pulseIconButton(systemName: "minus", color: .orange.opacity(0.9)) {
                    applyMinutes(viewModel.selectedDuration - 5)
                }

                Button(action: cyclePresetRing) {
                    VStack(spacing: 3) {
                        Text("\(viewModel.selectedDuration)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .animation(.easeInOut(duration: 0.22), value: viewModel.selectedDuration)
                        Text("点按换预设")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.cyan.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.cyan.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)

                pulseIconButton(systemName: "plus", color: .mint) {
                    applyMinutes(viewModel.selectedDuration + 5)
                }
            }

            HStack(spacing: 6) {
                ForEach(quickDots, id: \.self) { m in
                    let on = viewModel.selectedDuration == m
                    Circle()
                        .strokeBorder(on ? Color.cyan : Color.white.opacity(0.22), lineWidth: on ? 0 : 1)
                        .background(Circle().fill(on ? Color.cyan.opacity(0.35) : Color.clear))
                        .frame(width: 10, height: 10)
                        .onTapGesture { applyMinutes(m) }
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                customMinutesText = "\(viewModel.selectedDuration)"
                showCustomDurationSheet = true
            } label: {
                Label("手输其它分钟", systemImage: "keyboard")
                    .font(.caption2.weight(.semibold))
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.cyan.opacity(0.9))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func pulseIconButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }

    private var appShieldCard: some View {
        Button {
            viewModel.showPicker = true
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.5), Color.cyan.opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Label("AI 上锁", systemImage: "hand.raised.fill")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple.opacity(0.95), .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                    Text(appTileSubtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 4) {
                        Image(systemName: "apps.iphone")
                            .font(.caption2)
                        Text("轻点挑选")
                                .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(.cyan.opacity(0.85))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)

                if totalShieldCount > 0 {
                    Text("\(totalShieldCount)")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.black)
                        .padding(6)
                        .background(Circle().fill(Color.cyan))
                        .offset(x: -8, y: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 148)
        }
        .buttonStyle(ScaleOnPressButtonStyle())
    }

    private var backgroundRuleBubble: some View {
        Button {
            viewModel.failOnBackground.toggle()
            viewModel.saveSettings()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel.failOnBackground ? "app.badge.checkmark.fill" : "desktopwindow")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(viewModel.failOnBackground ? .orange : .cyan)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.failOnBackground ? "切后台 = 这棵树枯萎" : "允许短暂离开 App")
                        .font(.subheadline.weight(.semibold))
                    Text(viewModel.failOnBackground ? "像死守片场 · 再点可放宽" : "更温柔模式 · 点一下变严")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.07))
            )
        }
        .buttonStyle(.plain)
    }

    private var startButton: some View {
        Button {
            guard !showCustomDurationSheet else { return }
            commitCustomDurationField()
            onStart()
        } label: {
            Text("开始专注")
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.cyan)
    }

    private var customDurationSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("分钟（5–180）", text: $customMinutesText)
                        .keyboardType(.numberPad)
                        .onChange(of: customMinutesText) { newVal in
                            let digits = newVal.filter(\.isNumber)
                            if digits != newVal { customMinutesText = digits }
                        }
                } footer: {
                    Text("会立刻保存到本地，并用在下一轮专注。")
                }
            }
            .navigationTitle("自定义时长")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { showCustomDurationSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        commitCustomDurationField()
                        showCustomDurationSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func cyclePresetRing() {
        let cur = viewModel.selectedDuration
        if let idx = presetRing.firstIndex(of: cur) {
            let next = presetRing[(idx + 1) % presetRing.count]
            applyMinutes(next)
        } else {
            applyMinutes(presetRing[0])
        }
    }

    private func applyMinutes(_ m: Int) {
        let v = min(180, max(5, m))
        guard v != viewModel.selectedDuration else { return }
        viewModel.selectedDuration = v
        customMinutesText = "\(v)"
        viewModel.saveSettings()
    }

    private func commitCustomDurationField() {
        let digits = customMinutesText.filter(\.isNumber)
        guard let v = Int(digits), v > 0 else {
            customMinutesText = "\(viewModel.selectedDuration)"
            return
        }
        applyMinutes(v)
    }
}

// MARK: - 文明足迹（Sheet 内滚动）

private struct FocusForestSheet: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.records.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "leaf")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("还没有文明记录")
                            .font(.headline)
                        Text("完成几次专注，时间轴上会刻下你的演进。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.records) { record in
                            FocusRecordRow(record: record)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.black.opacity(0.2))
            .navigationTitle("文明足迹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 按压缩放

private struct ScaleOnPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - 记录行（与此前卡片风格一致）

private struct FocusRecordRow: View {
    let record: FocusRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: record.completed ? "leaf.circle.fill" : "xmark.circle")
                    .foregroundStyle(record.completed ? .green : .orange.opacity(0.9))
                Text(record.endedAt, format: .dateTime.month().day().hour().minute())
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(record.completed ? "完成" : "枯萎")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((record.completed ? Color.green : Color.orange).opacity(0.2))
                    )
                    .foregroundStyle(record.completed ? .green : .orange)
            }

            Text(record.achievementSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Label("计划 \(record.plannedMinutes) 分", systemImage: "timer")
                Label("实际 \(record.elapsedMinutes) 分", systemImage: "clock")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}
