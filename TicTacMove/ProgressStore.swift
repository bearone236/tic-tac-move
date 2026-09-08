import SwiftUI

/// A color scheme and mark shape for X/O, unlocked by cumulative wins.
struct Skin: Identifiable, Equatable {
    let id: String
    let name: String
    let xColor: Color
    let oColor: Color
    let style: MarkStyle
    let requiredWins: Int

    func color(for player: Player) -> Color {
        player == .x ? xColor : oColor
    }
}

/// Tracks total wins and the player's unlocked/equipped skin, persisted
/// across launches via UserDefaults. Wins are counted for X, since the
/// human always plays X in CPU mode (the default and primary mode).
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    static let skins: [Skin] = [
        Skin(id: "default", name: "デフォルト", xColor: Theme.xColor, oColor: Theme.oColor, style: .classic, requiredWins: 0),
        Skin(id: "sunrise", name: "サンライズ", xColor: Color(red: 1.0, green: 0.55, blue: 0.25), oColor: Color(red: 1.0, green: 0.25, blue: 0.35), style: .outline, requiredWins: 3),
        Skin(id: "forest", name: "フォレスト", xColor: Color(red: 0.45, green: 0.95, blue: 0.55), oColor: Color(red: 0.95, green: 0.85, blue: 0.35), style: .leaf, requiredWins: 10),
        Skin(id: "mono", name: "モノクローム", xColor: .white, oColor: Color(white: 0.55), style: .crystal, requiredWins: 25),
        Skin(id: "galaxy", name: "ギャラクシー", xColor: Color(red: 1.0, green: 0.85, blue: 0.35), oColor: Color(red: 0.55, green: 0.4, blue: 1.0), style: .cosmic, requiredWins: 50),
    ]

    private static let winsKey = "TicTacMove.totalWins"
    private static let skinKey = "TicTacMove.selectedSkinID"

    @Published private(set) var totalWins: Int
    @Published private(set) var selectedSkinID: String

    private init() {
        let defaults = UserDefaults.standard
        totalWins = defaults.integer(forKey: Self.winsKey)
        selectedSkinID = defaults.string(forKey: Self.skinKey) ?? Self.skins[0].id
    }

    var unlockedSkins: [Skin] {
        Self.skins.filter { $0.requiredWins <= totalWins }
    }

    var currentSkin: Skin {
        Self.skins.first(where: { $0.id == selectedSkinID }) ?? Self.skins[0]
    }

    func isUnlocked(_ skin: Skin) -> Bool {
        skin.requiredWins <= totalWins
    }

    /// Call once per finished game.
    func recordWin(for player: Player) {
        guard player == .x else { return }
        totalWins += 1
        UserDefaults.standard.set(totalWins, forKey: Self.winsKey)
    }

    func selectSkin(_ skin: Skin) {
        guard isUnlocked(skin) else { return }
        selectedSkinID = skin.id
        UserDefaults.standard.set(skin.id, forKey: Self.skinKey)
    }
}
