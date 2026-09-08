import SwiftUI

/// How a skin renders its X/O marks — not just a color, but an actual
/// different silhouette, so unlocking a skin visibly changes the board.
enum MarkStyle: Hashable {
    case classic   // bold filled glyph (the original look)
    case outline   // thin hollow line-art
    case leaf      // crossed leaf shapes / a vine-like dashed ring
    case crystal   // faceted double-line geometry
    case cosmic    // starburst / orbiting satellite accents
}

/// Renders a single X or O in the given style and color, sized to fill
/// whatever frame it's given.
struct PieceGlyph: View {
    let player: Player
    let style: MarkStyle
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            content(size: size)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private func content(size: CGFloat) -> some View {
        switch style {
        case .classic:
            Text(player.rawValue)
                .font(.system(size: size * 0.85, weight: .heavy, design: .rounded))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .outline:
            if player == .x {
                CrossMark()
                    .stroke(color, style: StrokeStyle(lineWidth: size * 0.13, lineCap: .round))
                    .frame(width: size * 0.68, height: size * 0.68)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Circle()
                    .stroke(color, lineWidth: size * 0.13)
                    .frame(width: size * 0.7, height: size * 0.7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        case .leaf:
            if player == .x {
                ZStack {
                    LeafMark().fill(color).frame(width: size * 0.72, height: size * 0.26).rotationEffect(.degrees(45))
                    LeafMark().fill(color).frame(width: size * 0.72, height: size * 0.26).rotationEffect(.degrees(-45))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Circle()
                    .stroke(color, style: StrokeStyle(lineWidth: size * 0.11, dash: [size * 0.09, size * 0.075]))
                    .frame(width: size * 0.7, height: size * 0.7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        case .crystal:
            if player == .x {
                ZStack {
                    DiamondMark()
                        .stroke(color.opacity(0.55), lineWidth: size * 0.035)
                        .frame(width: size * 0.78, height: size * 0.78)
                    CrossMark()
                        .stroke(color, style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round))
                        .frame(width: size * 0.5, height: size * 0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Circle().stroke(color, lineWidth: size * 0.05).frame(width: size * 0.7, height: size * 0.7)
                    Circle().stroke(color.opacity(0.6), lineWidth: size * 0.03).frame(width: size * 0.46, height: size * 0.46)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        case .cosmic:
            if player == .x {
                ZStack {
                    CrossMark()
                        .stroke(color, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round))
                        .frame(width: size * 0.68, height: size * 0.68)
                    StarMark(points: 4)
                        .fill(color)
                        .frame(width: size * 0.26, height: size * 0.26)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Circle().stroke(color, lineWidth: size * 0.11).frame(width: size * 0.68, height: size * 0.68)
                    Circle().fill(color).frame(width: size * 0.11, height: size * 0.11)
                        .offset(x: size * 0.28, y: -size * 0.26)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

private struct CrossMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

private struct DiamondMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

/// A pointed lens (vesica piscis) shape — used as a stylized leaf.
private struct LeafMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

private struct StarMark: Shape {
    var points: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.42
        let totalPoints = points * 2

        var path = Path()
        for i in 0..<totalPoints {
            let angle = (Double(i) / Double(totalPoints)) * 2 * .pi - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach([MarkStyle.classic, .outline, .leaf, .crystal, .cosmic], id: \.self) { style in
            HStack(spacing: 24) {
                PieceGlyph(player: .x, style: style, color: Theme.xColor).frame(width: 60, height: 60)
                PieceGlyph(player: .o, style: style, color: Theme.oColor).frame(width: 60, height: 60)
            }
        }
    }
    .padding()
    .background(Theme.background)
}
