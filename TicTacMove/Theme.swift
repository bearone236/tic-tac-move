import SwiftUI

/// Shared look-and-feel: a near-black, neon-accented theme used across every screen.
enum Theme {
    static let background = LinearGradient(
        colors: [Color(red: 0.01, green: 0.01, blue: 0.04), Color(red: 0.05, green: 0.02, blue: 0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardFill = Color.white.opacity(0.05)
    static let cardStroke = Color.white.opacity(0.10)

    static let xColor = Color(red: 0.30, green: 0.90, blue: 1.0)      // neon cyan
    static let oColor = Color(red: 1.0, green: 0.28, blue: 0.62)      // neon pink
    static let accent = Color(red: 0.62, green: 0.42, blue: 1.0)      // neon violet

    static func markColor(for player: Player) -> Color {
        player == .x ? xColor : oColor
    }
}
