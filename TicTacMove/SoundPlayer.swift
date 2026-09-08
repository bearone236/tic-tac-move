import AVFoundation

/// Tiny wrapper around AVAudioPlayer for the game's self-contained,
/// synthesized sound effects and ambient loop.
final class SoundPlayer {
    static let shared = SoundPlayer()

    enum Effect: String {
        case select = "sfx_select"
        case piece = "sfx_piece"
        case win = "sfx_win"
    }

    private var effectPlayers: [Effect: AVAudioPlayer] = [:]
    private var bgmPlayer: AVAudioPlayer?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for effect in [Effect.select, .piece, .win] {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else { continue }
            let player = try? AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            effectPlayers[effect] = player
        }
    }

    func play(_ effect: Effect) {
        guard let player = effectPlayers[effect] else { return }
        player.currentTime = 0
        player.volume = 0.8
        player.play()
    }

    func startBGM() {
        if let bgmPlayer, !bgmPlayer.isPlaying {
            bgmPlayer.play()
            return
        }
        guard bgmPlayer == nil, let url = Bundle.main.url(forResource: "bgm_ambient", withExtension: "wav") else { return }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = 0.25
        player?.prepareToPlay()
        player?.play()
        bgmPlayer = player
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }
}
