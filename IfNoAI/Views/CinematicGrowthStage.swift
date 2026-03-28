import SwiftUI
import UIKit

/// 分层舞台：天空 / 星尘 / 天体 / 远山 / 天际线 / 灯火 / 雾 / 暗角 —— 进度驱动关键帧插值 + 时间轴环境动画
struct CinematicGrowthStage: View {
    var progress: Double
    var isWithered: Bool
    var isPreviewMode: Bool

    private var effectiveProgress: Double {
        min(1, max(0, isPreviewMode ? 0.12 : progress))
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let theme = JourneyVisualTrack.interpolated(at: effectiveProgress, withered: isWithered)

                ZStack {
                    skyLayer(theme: theme, size: geo.size)

                    StarsAndMotesCanvas(phase: phase, starAlpha: theme.starAlpha)
                        .opacity(isWithered ? 0.35 : 1)

                    CelestialOrb(
                        phase: phase,
                        progress: CGFloat(effectiveProgress),
                        theme: theme,
                        size: geo.size,
                        withered: isWithered
                    )

                    FarMountains(progress: CGFloat(effectiveProgress), opacity: theme.mountainOpacity, size: geo.size)

                    HorizonBand(theme: theme, width: geo.size.width, height: geo.size.height)

                    CityLightField(
                        phase: phase,
                        progress: CGFloat(effectiveProgress),
                        warmth: theme.windowWarmth,
                        size: geo.size
                    )

                    AtmosphericFog(opacity: theme.fogOpacity, size: geo.size)

                    RisingEmberDrift(phase: phase, intensity: CGFloat(effectiveProgress), size: geo.size)
                        .opacity(isWithered ? 0.15 : 0.55)

                    CinematicVignette(size: geo.size)

                    if isWithered {
                        ZStack {
                            Color.black.opacity(0.4)
                            Color.gray.opacity(0.1)
                        }
                        .blendMode(.multiply)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.16), .cyan.opacity(0.12), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    private func skyLayer(theme: JourneyKeyframe, size: CGSize) -> some View {
        LinearGradient(
            stops: [
                .init(color: theme.skyTop, location: 0),
                .init(color: theme.skyMid, location: 0.48),
                .init(color: theme.skyBottom, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - 主题轨道（关键帧 → 连续插值）

private struct JourneyKeyframe {
    var skyTop: Color
    var skyMid: Color
    var skyBottom: Color
    var horizonGlow: Color
    var sunCore: Color
    var sunHalo: Color
    var sunScale: CGFloat
    var mountainOpacity: CGFloat
    var starAlpha: CGFloat
    var windowWarmth: CGFloat
    var fogOpacity: CGFloat

    func lerped(to b: JourneyKeyframe, t: CGFloat) -> JourneyKeyframe {
        let u = min(1, max(0, t))
        return JourneyKeyframe(
            skyTop: lerpColor(skyTop, b.skyTop, u),
            skyMid: lerpColor(skyMid, b.skyMid, u),
            skyBottom: lerpColor(skyBottom, b.skyBottom, u),
            horizonGlow: lerpColor(horizonGlow, b.horizonGlow, u),
            sunCore: lerpColor(sunCore, b.sunCore, u),
            sunHalo: lerpColor(sunHalo, b.sunHalo, u),
            sunScale: sunScale + (b.sunScale - sunScale) * u,
            mountainOpacity: mountainOpacity + (b.mountainOpacity - mountainOpacity) * u,
            starAlpha: starAlpha + (b.starAlpha - starAlpha) * u,
            windowWarmth: windowWarmth + (b.windowWarmth - windowWarmth) * u,
            fogOpacity: fogOpacity + (b.fogOpacity - fogOpacity) * u
        )
    }
}

private enum JourneyVisualTrack {
    /// 与 `CivilizationEra` 八阶一一对应：荒原 → … → 城市文明
    static let keyframes: [JourneyKeyframe] = [
        JourneyKeyframe(
            skyTop: Color(red: 0.11, green: 0.08, blue: 0.10),
            skyMid: Color(red: 0.16, green: 0.10, blue: 0.10),
            skyBottom: Color(red: 0.22, green: 0.14, blue: 0.11),
            horizonGlow: Color(red: 0.38, green: 0.22, blue: 0.16),
            sunCore: Color(red: 0.50, green: 0.30, blue: 0.20),
            sunHalo: Color(red: 0.32, green: 0.16, blue: 0.12),
            sunScale: 0.70,
            mountainOpacity: 0.64,
            starAlpha: 0.58,
            windowWarmth: 0,
            fogOpacity: 0.40
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.05, green: 0.10, blue: 0.18),
            skyMid: Color(red: 0.10, green: 0.18, blue: 0.26),
            skyBottom: Color(red: 0.14, green: 0.28, blue: 0.30),
            horizonGlow: Color(red: 0.22, green: 0.42, blue: 0.45),
            sunCore: Color(red: 0.42, green: 0.72, blue: 0.68),
            sunHalo: Color(red: 0.12, green: 0.42, blue: 0.45),
            sunScale: 0.78,
            mountainOpacity: 0.54,
            starAlpha: 0.40,
            windowWarmth: 0.02,
            fogOpacity: 0.30
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.06, green: 0.14, blue: 0.14),
            skyMid: Color(red: 0.12, green: 0.28, blue: 0.22),
            skyBottom: Color(red: 0.20, green: 0.40, blue: 0.28),
            horizonGlow: Color(red: 0.32, green: 0.52, blue: 0.30),
            sunCore: Color(red: 0.60, green: 0.78, blue: 0.38),
            sunHalo: Color(red: 0.18, green: 0.50, blue: 0.32),
            sunScale: 0.90,
            mountainOpacity: 0.48,
            starAlpha: 0.26,
            windowWarmth: 0.08,
            fogOpacity: 0.22
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.16, green: 0.08, blue: 0.08),
            skyMid: Color(red: 0.35, green: 0.16, blue: 0.12),
            skyBottom: Color(red: 0.48, green: 0.26, blue: 0.14),
            horizonGlow: Color(red: 0.88, green: 0.45, blue: 0.18),
            sunCore: Color(red: 0.95, green: 0.55, blue: 0.22),
            sunHalo: Color(red: 0.55, green: 0.20, blue: 0.12),
            sunScale: 1.0,
            mountainOpacity: 0.42,
            starAlpha: 0.16,
            windowWarmth: 0.22,
            fogOpacity: 0.18
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.12, green: 0.07, blue: 0.14),
            skyMid: Color(red: 0.26, green: 0.14, blue: 0.20),
            skyBottom: Color(red: 0.38, green: 0.22, blue: 0.18),
            horizonGlow: Color(red: 0.72, green: 0.38, blue: 0.22),
            sunCore: Color(red: 0.92, green: 0.50, blue: 0.28),
            sunHalo: Color(red: 0.45, green: 0.18, blue: 0.15),
            sunScale: 1.04,
            mountainOpacity: 0.38,
            starAlpha: 0.12,
            windowWarmth: 0.38,
            fogOpacity: 0.15
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.10, green: 0.12, blue: 0.18),
            skyMid: Color(red: 0.18, green: 0.22, blue: 0.30),
            skyBottom: Color(red: 0.28, green: 0.30, blue: 0.32),
            horizonGlow: Color(red: 0.48, green: 0.50, blue: 0.38),
            sunCore: Color(red: 0.85, green: 0.72, blue: 0.45),
            sunHalo: Color(red: 0.30, green: 0.38, blue: 0.48),
            sunScale: 1.06,
            mountainOpacity: 0.34,
            starAlpha: 0.09,
            windowWarmth: 0.50,
            fogOpacity: 0.12
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.07, green: 0.06, blue: 0.16),
            skyMid: Color(red: 0.12, green: 0.10, blue: 0.26),
            skyBottom: Color(red: 0.20, green: 0.14, blue: 0.34),
            horizonGlow: Color(red: 0.40, green: 0.28, blue: 0.58),
            sunCore: Color(red: 0.45, green: 0.48, blue: 0.88),
            sunHalo: Color(red: 0.22, green: 0.24, blue: 0.52),
            sunScale: 1.10,
            mountainOpacity: 0.30,
            starAlpha: 0.06,
            windowWarmth: 0.72,
            fogOpacity: 0.09
        ),
        JourneyKeyframe(
            skyTop: Color(red: 0.02, green: 0.04, blue: 0.08),
            skyMid: Color(red: 0.05, green: 0.10, blue: 0.18),
            skyBottom: Color(red: 0.08, green: 0.20, blue: 0.28),
            horizonGlow: Color(red: 0.12, green: 0.72, blue: 0.80),
            sunCore: Color(red: 0.82, green: 0.94, blue: 1.0),
            sunHalo: Color(red: 0.04, green: 0.52, blue: 0.62),
            sunScale: 1.16,
            mountainOpacity: 0.26,
            starAlpha: 0.03,
            windowWarmth: 1.0,
            fogOpacity: 0.05
        )
    ]

    static func interpolated(at progress: Double, withered: Bool) -> JourneyKeyframe {
        let p = CGFloat(min(1, max(0, progress)))
        let track = p * 7
        let i = min(6, max(0, Int(floor(Double(track)))))
        let f = track - CGFloat(i)
        var k = keyframes[i].lerped(to: keyframes[i + 1], t: f)
        if withered {
            let dead = JourneyKeyframe(
                skyTop: Color(red: 0.12, green: 0.12, blue: 0.12),
                skyMid: Color(red: 0.15, green: 0.15, blue: 0.15),
                skyBottom: Color(red: 0.18, green: 0.18, blue: 0.18),
                horizonGlow: Color(red: 0.28, green: 0.28, blue: 0.28),
                sunCore: Color(red: 0.38, green: 0.38, blue: 0.38),
                sunHalo: Color(red: 0.22, green: 0.22, blue: 0.22),
                sunScale: k.sunScale * 0.82,
                mountainOpacity: k.mountainOpacity * 0.72,
                starAlpha: k.starAlpha * 0.38,
                windowWarmth: k.windowWarmth * 0.3,
                fogOpacity: min(0.58, k.fogOpacity + 0.26)
            )
            k = k.lerped(to: dead, t: 0.58)
        }
        return k
    }
}

// MARK: - 星尘画布

private struct StarsAndMotesCanvas: View {
    var phase: TimeInterval
    var starAlpha: CGFloat

    var body: some View {
        Canvas { context, csize in
            guard starAlpha > 0.02 else { return }
            for i in 0..<36 {
                let x = pseudoRandom(i, seed: 1) * csize.width
                let y = pseudoRandom(i, seed: 3) * csize.height * 0.52
                let tw = 0.45 + 0.55 * sin(phase * 1.8 + Double(i) * 0.7)
                let o = Double(starAlpha) * tw
                let d = CGFloat(1 + (i % 3))
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: d, height: d)),
                    with: .color(Color.white.opacity(o))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func pseudoRandom(_ i: Int, seed: Int) -> CGFloat {
        let v = sin(Double(i * seed) * 12.9898) * 43758.5453
        let f = abs(v - floor(v))
        return CGFloat(f)
    }
}

// MARK: - 天体（东升 + 呼吸感）

private struct CelestialOrb: View {
    var phase: TimeInterval
    var progress: CGFloat
    var theme: JourneyKeyframe
    var size: CGSize
    var withered: Bool

    var body: some View {
        let breathe: CGFloat = 1 + 0.045 * CGFloat(sin(phase * 1.15))
        let travel = progress * 0.46 * size.height
        let x = size.width * (0.26 + progress * 0.38)
        let y = size.height * 0.68 - travel
        let r = 28 * theme.sunScale * breathe * (withered ? 0.85 : 1)

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.sunCore.opacity(0.95), theme.sunHalo.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: r * 2.2
                    )
                )
                .frame(width: r * 2.6, height: r * 2.6)
                .blur(radius: withered ? 6 : 3)
            Circle()
                .fill(theme.sunCore)
                .frame(width: r * 0.55, height: r * 0.55)
                .blur(radius: 1.2)
        }
        .position(x: x, y: y)
        .animation(.easeInOut(duration: 1.85), value: progress)
    }
}

// MARK: - 远山（视差）

private struct FarMountains: View {
    var progress: CGFloat
    var opacity: CGFloat
    var size: CGSize

    var body: some View {
        let shift = progress * 14
        ZStack(alignment: .bottom) {
            mountainShape(offset: shift * 0.6, color: Color.black.opacity(Double(opacity * 0.9)))
                .frame(height: size.height * 0.42)
            mountainShape(offset: -shift, color: Color.black.opacity(Double(opacity * 0.72)))
                .frame(height: size.height * 0.36)
        }
        .frame(width: size.width, height: size.height, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private func mountainShape(offset: CGFloat, color: Color) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: -20 + offset, y: h + 10))
                p.addLine(to: CGPoint(x: w * 0.08 + offset, y: h * 0.35))
                p.addLine(to: CGPoint(x: w * 0.22 + offset, y: h * 0.52))
                p.addLine(to: CGPoint(x: w * 0.38 + offset, y: h * 0.28))
                p.addLine(to: CGPoint(x: w * 0.55 + offset, y: h * 0.48))
                p.addLine(to: CGPoint(x: w * 0.72 + offset, y: h * 0.22))
                p.addLine(to: CGPoint(x: w * 0.88 + offset, y: h * 0.45))
                p.addLine(to: CGPoint(x: w + 20 + offset, y: h + 10))
                p.closeSubpath()
            }
            .fill(color)
        }
    }
}

// MARK: - 天际光带

private struct HorizonBand: View {
    var theme: JourneyKeyframe
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [theme.horizonGlow.opacity(0), theme.horizonGlow.opacity(0.55), theme.horizonGlow.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.2)
            .blur(radius: 8)
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}

// MARK: - 城市灯火（Canvas）

private struct CityLightField: View {
    var phase: TimeInterval
    var progress: CGFloat
    var warmth: CGFloat
    var size: CGSize

    var body: some View {
        Canvas { context, csize in
            let count = max(0, Int(ceil(Double(progress) * 38)))
            guard count > 0 else { return }
            let warm = max(0.08, Double(warmth))
            for i in 0..<count {
                let px = pseudoRandom(i, seed: 7) * Double(csize.width)
                let rowHeight = Double(csize.height) * 0.38
                let py = rowHeight + pseudoRandom(i, seed: 9) * 26
                let w = 1.5 + pseudoRandom(i, seed: 2) * 2.2
                let h = 3 + pseudoRandom(i, seed: 4) * (5 + warm * 6)
                let flicker = 0.65 + 0.35 * sin(phase * 2.4 + Double(i) * 0.51)
                let orange = Color(red: 0.9 * warm + 0.1, green: 0.55 * warm + 0.08, blue: 0.2 * warm + 0.05)
                let rect = CGRect(x: px, y: py, width: w, height: h)
                context.fill(
                    Path(roundedRect: rect, cornerRadius: 0.6),
                    with: .color(orange.opacity(Double(progress) * flicker * (0.35 + warm * 0.55)))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func pseudoRandom(_ i: Int, seed: Int) -> Double {
        let v = sin(Double(i * seed) * 12.9898) * 43758.5453
        return abs(v - floor(v))
    }
}

// MARK: - 雾

private struct AtmosphericFog: View {
    var opacity: CGFloat
    var size: CGSize

    var body: some View {
        LinearGradient(
            colors: [Color.white.opacity(0), Color.white.opacity(Double(opacity * 0.12)), Color.clear],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

// MARK: - 飞尘微粒

private struct RisingEmberDrift: View {
    var phase: TimeInterval
    var intensity: CGFloat
    var size: CGSize

    var body: some View {
        Canvas { context, csize in
            guard intensity > 0.05 else { return }
            for i in 0..<18 {
                let baseX = pseudoRandom(i + 3, seed: 11) * Double(csize.width)
                let speed = 12 + pseudoRandom(i, seed: 5) * 18
                let y = Double(csize.height) - (phase * speed + Double(i * 7)).truncatingRemainder(dividingBy: Double(csize.height) * 0.85)
                let x = baseX + sin(phase * 0.8 + Double(i)) * 14 * Double(intensity)
                let o = Double(intensity) * 0.22 * (0.4 + 0.6 * pseudoRandom(i, seed: 8))
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                    with: .color(Color.cyan.opacity(o))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func pseudoRandom(_ i: Int, seed: Int) -> Double {
        let v = sin(Double(i * seed) * 12.9898) * 43758.5453
        return abs(v - floor(v))
    }
}

// MARK: - 暗角

private struct CinematicVignette: View {
    var size: CGSize

    var body: some View {
        RadialGradient(
            colors: [.clear, .black.opacity(0.55), .black.opacity(0.82)],
            center: .center,
            startRadius: size.width * 0.22,
            endRadius: size.width * 0.72
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Color 插值

private func lerpColor(_ a: Color, _ b: Color, _ t: CGFloat) -> Color {
    let ua = UIColor(a)
    let ub = UIColor(b)
    var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
    var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
    guard ua.getRed(&ar, green: &ag, blue: &ab, alpha: &aa),
          ub.getRed(&br, green: &bg, blue: &bb, alpha: &ba) else {
        return t < 0.5 ? a : b
    }
    return Color(
        red: Double(ar + (br - ar) * t),
        green: Double(ag + (bg - ag) * t),
        blue: Double(ab + (bb - ab) * t),
        opacity: Double(aa + (ba - aa) * t)
    )
}