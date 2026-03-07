import SwiftUI

/// Full-screen confetti particle celebration using TimelineView + Canvas.
///
/// Particles fall from y = 0, sway horizontally, and fade out over `duration` seconds.
/// The view is non-interactive (`allowsHitTesting(false)`) and must be used as an overlay.
///
/// Usage:
/// ```swift
/// .overlay { if showConfetti { ConfettiView() } }
/// ```
struct ConfettiView: View {

    var particleCount: Int = 120
    var duration: Double    = 3.5

    // MARK: - Particle Model

    private struct Particle {
        let xFraction:   CGFloat   // initial X as fraction of view width
        let fallSpeed:   CGFloat   // px/sec (initial downward velocity)
        let driftX:      CGFloat   // px/sec lateral drift
        let sway:        CGFloat   // amplitude of horizontal sine wave (px)
        let swayFreq:    Double    // sine frequency (Hz)
        let color:       Color
        let width:       CGFloat
        let height:      CGFloat
        let delay:       Double    // seconds before particle becomes visible
    }

    // MARK: - State

    @State private var particles: [Particle] = []
    @State private var birthDate = Date()

    // MARK: - Body

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSince(birthDate)
                for p in particles {
                    let elapsed = t - p.delay
                    guard elapsed > 0 else { continue }
                    let opacity = max(0, 1.0 - elapsed / duration)
                    guard opacity > 0 else { continue }

                    // Physics: gravity accelerates fall
                    let y = p.fallSpeed * CGFloat(elapsed) + 0.5 * 220 * CGFloat(elapsed * elapsed)
                    let sway = p.sway * CGFloat(sin(elapsed * p.swayFreq * .pi * 2))
                    let x = p.xFraction * size.width + p.driftX * CGFloat(elapsed) + sway

                    var pctx = ctx
                    pctx.opacity = opacity

                    let rect = CGRect(x: x - p.width / 2, y: y - p.height / 2,
                                     width: p.width, height: p.height)
                    pctx.fill(Path(roundedRect: rect, cornerRadius: 1.5), with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
            birthDate = Date()
            particles  = makeParticles()
        }
    }

    // MARK: - Particle Generation

    private func makeParticles() -> [Particle] {
        let palette: [Color] = [
            .red, .orange, .yellow, .green, .blue,
            .purple, .pink, .cyan, .mint, .teal
        ]
        return (0..<particleCount).map { i in
            Particle(
                xFraction: CGFloat.random(in: 0.05...0.95),
                fallSpeed: CGFloat.random(in: 80...200),
                driftX:    CGFloat.random(in: -40...40),
                sway:      CGFloat.random(in: 18...55),
                swayFreq:  Double.random(in: 0.7...2.0),
                color:     palette[i % palette.count],
                width:     CGFloat.random(in: 8...14),
                height:    CGFloat.random(in: 5...9),
                delay:     Double(i) * (1.8 / Double(particleCount))
            )
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        ConfettiView()
    }
}
