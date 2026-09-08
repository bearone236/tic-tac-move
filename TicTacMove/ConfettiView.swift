import SwiftUI

/// A lightweight celebratory particle burst shown when a player wins.
struct ConfettiView: View {
    private let pieceCount = 36
    private let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple, .pink]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieceCount, id: \.self) { i in
                    ConfettiPiece(
                        color: colors[i % colors.count],
                        startX: CGFloat.random(in: 0...geo.size.width),
                        endY: geo.size.height + 60,
                        size: CGFloat.random(in: 6...11),
                        delay: Double.random(in: 0...0.35),
                        duration: Double.random(in: 1.3...2.0)
                    )
                }
            }
        }
    }
}

private struct ConfettiPiece: View {
    let color: Color
    let startX: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let delay: Double
    let duration: Double

    @State private var offsetY: CGFloat = -40
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: size, height: size * 1.7)
            .rotationEffect(.degrees(rotation))
            .position(x: startX, y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    offsetY = endY
                    rotation = Double.random(in: 180...720)
                }
                withAnimation(.easeIn(duration: 0.4).delay(delay + duration - 0.4)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    ConfettiView()
        .background(Color.black)
}
