import SwiftUI

/// Animated circular arc showing visited / total stops ratio.
///
/// The arc fills from 0 → fraction on first appear with a spring animation.
/// Turns green when every stop has been visited.
struct TripProgressRingView: View {

    let visited: Int
    let total: Int
    var lineWidth: CGFloat = 5

    @State private var animatedProgress: Double = 0

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return min(Double(visited) / Double(total), 1.0)
    }

    private var ringColor: Color { fraction >= 1.0 ? .green : .blue }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: lineWidth)

            // Filled arc
            Circle()
                .trim(from: 0, to: fraction * animatedProgress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(ringColor)
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.9, bounce: 0.2), value: animatedProgress)

            // Centre label
            if total > 0 {
                VStack(spacing: 0) {
                    Text("\(visited)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ringColor)
                    Text("/\(total)")
                        .font(.system(size: 8, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "mappin")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { animatedProgress = 1.0 }
    }
}

#Preview {
    HStack(spacing: 20) {
        TripProgressRingView(visited: 0,  total: 8)  .frame(width: 44, height: 44)
        TripProgressRingView(visited: 3,  total: 8)  .frame(width: 44, height: 44)
        TripProgressRingView(visited: 8,  total: 8)  .frame(width: 44, height: 44)
        TripProgressRingView(visited: 0,  total: 0)  .frame(width: 44, height: 44)
    }
    .padding()
}
