import SwiftUI

/// A slow, glowing starfield used behind every screen for a more immersive,
/// cyber-ish atmosphere than a flat gradient.
struct AmbientBackground: View {
    private let colors: [Color] = [Theme.xColor, Theme.oColor, Theme.accent]
    private let count = 22

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Theme.background
                ForEach(0..<count, id: \.self) { i in
                    DriftingParticle(
                        color: colors[i % colors.count],
                        size: CGFloat.random(in: 2...5),
                        startX: CGFloat.random(in: 0...max(geo.size.width, 1)),
                        startY: CGFloat.random(in: 0...max(geo.size.height, 1)),
                        duration: Double.random(in: 4...9)
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct DriftingParticle: View {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let duration: Double

    @State private var drift: CGFloat = 0
    @State private var twinkle = 0.2

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color, radius: size)
            .opacity(twinkle)
            .position(x: startX, y: startY + drift)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    drift = -26
                }
                withAnimation(.easeInOut(duration: duration * 0.6).repeatForever(autoreverses: true)) {
                    twinkle = 0.85
                }
            }
    }
}

#Preview {
    AmbientBackground()
}
