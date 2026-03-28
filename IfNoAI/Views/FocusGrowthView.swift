import SwiftUI

/// 外层编排：文明史旁白 + 演进舞台 + 阶段胶片条
struct FocusGrowthView: View {
    var progress: Double
    var isWithered: Bool
    var isIdlePreview: Bool
    var compact: Bool = false

    private var narrativeProgress: Double {
        min(1, max(0, isIdlePreview ? 0.06 : progress))
    }

    private var currentEra: CivilizationEra {
        CivilizationEra.era(for: narrativeProgress)
    }

    private var stageHeight: CGFloat { compact ? 118 : 248 }
    private var outerSpacing: CGFloat { compact ? 8 : 20 }

    var body: some View {
        VStack(spacing: outerSpacing) {
            header

            CinematicGrowthStage(
                progress: progress,
                isWithered: isWithered,
                isPreviewMode: isIdlePreview
            )
            .frame(height: stageHeight)
            .animation(.easeInOut(duration: 2.15), value: narrativeProgress)
            .animation(.spring(response: 1.1, dampingFraction: 0.78), value: currentEra.id)

            CivilizationEraFilmstrip(
                progress: progress,
                isWithered: isWithered,
                previewAllLit: isIdlePreview,
                compact: compact
            )
        }
    }

    @ViewBuilder
    private var header: some View {
        if isIdlePreview {
            if compact {
                EmptyView()
            } else {
                Text("专注进行中，时间在推着文明向前")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        } else {
            Text(blurbLine)
                .font(compact ? .caption : .system(.subheadline, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .lineLimit(compact ? 2 : nil)
                .minimumScaleFactor(compact ? 0.85 : 1)
                .animation(.easeInOut(duration: 0.85), value: currentEra.id)
                .id(currentEra.id)
        }
    }

    private var blurbLine: String {
        if isWithered { return "轨道已断 · 只剩风在空城里兜圈" }
        if progress >= 0.999 { return CivilizationEra.era(for: 1).narrativeLine }
        return currentEra.narrativeLine
    }
}

// MARK: - 八阶胶片导航

private struct CivilizationEraFilmstrip: View {
    var progress: Double
    var isWithered: Bool
    var previewAllLit: Bool
    var compact: Bool = false

    private var activeIndex: Int {
        CivilizationEra.era(for: progress).rawValue
    }

    var body: some View {
        Group {
            if compact {
                HStack(spacing: 3) {
                    ForEach(CivilizationEra.allCases) { era in
                        let idx = era.rawValue
                        let lit = previewAllLit || idx <= activeIndex
                        let isCurrent = !previewAllLit && idx == activeIndex
                        Capsule()
                            .fill(barColor(lit: lit, current: isCurrent))
                            .frame(height: isCurrent ? 4 : 2)
                            .shadow(color: glowColor(isCurrent: isCurrent), radius: isCurrent ? 5 : 0, y: 0)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 2)
            } else {
                HStack(alignment: .top, spacing: 4) {
                    ForEach(CivilizationEra.allCases) { era in
                        let idx = era.rawValue
                        let lit = previewAllLit || idx <= activeIndex
                        let isCurrent = !previewAllLit && idx == activeIndex

                        VStack(spacing: 5) {
                            Capsule()
                                .fill(barColor(lit: lit, current: isCurrent))
                                .frame(height: isCurrent ? 4 : 2)
                                .shadow(color: glowColor(isCurrent: isCurrent), radius: isCurrent ? 7 : 0, y: 0)

                            Image(systemName: era.symbolName)
                                .font(.system(size: 10, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(iconColor(lit: lit, current: isCurrent))

                            Text(era.title)
                                .font(.system(size: 7, weight: isCurrent ? .bold : .medium, design: .rounded))
                                .foregroundStyle(labelStyle(lit: lit, current: isCurrent))
                                .lineLimit(1)
                                .minimumScaleFactor(0.55)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .animation(.spring(response: 0.92, dampingFraction: 0.76), value: activeIndex)
    }

    private func glowColor(isCurrent: Bool) -> Color {
        guard isCurrent, !isWithered else { return .clear }
        return Color.cyan.opacity(0.75)
    }

    private func barColor(lit: Bool, current: Bool) -> Color {
        if isWithered { return lit ? Color.gray.opacity(0.55) : Color.white.opacity(0.1) }
        if !lit { return Color.white.opacity(0.1) }
        return current ? Color.cyan : Color.cyan.opacity(0.38)
    }

    private func iconColor(lit: Bool, current: Bool) -> Color {
        if isWithered { return lit ? Color.gray : Color.white.opacity(0.38) }
        if !lit { return Color.white.opacity(0.38) }
        return current ? Color.cyan : Color.white.opacity(0.72)
    }

    private func labelStyle(lit: Bool, current: Bool) -> Color {
        if isWithered { return lit ? Color.white.opacity(0.55) : Color.white.opacity(0.38) }
        if !lit { return Color.white.opacity(0.38) }
        return current ? Color.white : Color.white.opacity(0.62)
    }
}
