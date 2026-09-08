import SwiftUI

/// Shared look-and-feel: a dark, neon-accented theme used across every screen.
enum Theme {
    static let background = LinearGradient(
        colors: [Color(red: 0.04, green: 0.05, blue: 0.12), Color(red: 0.10, green: 0.06, blue: 0.20)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardFill = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.12)

    static let xColor = Color(red: 0.35, green: 0.85, blue: 1.0)      // neon cyan
    static let oColor = Color(red: 1.0, green: 0.35, blue: 0.65)      // neon pink
    static let accent = Color(red: 0.55, green: 0.45, blue: 1.0)      // neon violet

    static func markColor(for player: Player) -> Color {
        player == .x ? xColor : oColor
    }
}
