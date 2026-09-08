import SwiftUI

struct HomeView: View {
    @StateObject private var engine = GameEngine()
    @ObservedObject private var progress = ProgressStore.shared
    @State private var isVsCPU = true
    @State private var startGame = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(spacing: 0) {
                    Spacer()

                    titleBlock

                    Spacer()

                    VStack(spacing: 20) {
                        modePicker

                        Button {
                            engine.isCPUOpponent = isVsCPU
                            engine.reset()
                            startGame = true
                        } label: {
                            Label("対戦を始める", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent)

                        HStack(spacing: 12) {
                            NavigationLink {
                                HowToPlayView()
                            } label: {
                                Label("遊び方", systemImage: "questionmark.circle")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                            }

                            NavigationLink {
                                SkinsView()
                            } label: {
                                Label("スキン", systemImage: "paintpalette")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $startGame) {
                GameView(engine: engine)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var modePicker: some View {
        Picker("対戦モード", selection: $isVsCPU) {
            Text("CPU対戦").tag(true)
            Text("2人プレイ").tag(false)
        }
        .pickerStyle(.segmented)
    }

    private var titleBlock: some View {
        let skin = progress.currentSkin
        return ZStack {
            FloatingMark(text: "X", color: skin.xColor)
                .offset(x: -90, y: -30)
            FloatingMark(text: "O", color: skin.oColor)
                .offset(x: 96, y: 40)

            VStack(spacing: 10) {
                Text("Tic Tac Move")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [skin.xColor, Theme.accent, skin.oColor], startPoint: .leading, endPoint: .trailing)
                    )
                Text("置いて、動かして、揃えよう")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

private struct FloatingMark: View {
    let text: String
    let color: Color

    @State private var offsetY: CGFloat = 0

    var body: some View {
        Text(text)
            .font(.system(size: 96, weight: .heavy, design: .rounded))
            .foregroundStyle(color.opacity(0.18))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    offsetY = -16
                }
            }
    }
}

#Preview {
    HomeView()
}
