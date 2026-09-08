import SwiftUI

struct HomeView: View {
    @StateObject private var engine = GameEngine()

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()

                VStack(spacing: 0) {
                    Spacer()

                    titleBlock

                    Spacer()

                    VStack(spacing: 16) {
                        NavigationLink {
                            GameView(engine: engine)
                        } label: {
                            Label("対戦を始める", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)

                        NavigationLink {
                            HowToPlayView()
                        } label: {
                            Label("遊び方", systemImage: "questionmark.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.bordered)
                        .tint(.indigo)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
        }
    }

    private var titleBlock: some View {
        ZStack {
            FloatingMark(text: "X", color: .blue)
                .offset(x: -90, y: -30)
            FloatingMark(text: "O", color: .red)
                .offset(x: 96, y: 40)

            VStack(spacing: 10) {
                Text("Tic Tac Move")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                Text("置いて、動かして、揃えよう")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
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
            .foregroundStyle(color.opacity(0.16))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    offsetY = -16
                }
            }
    }
}

private struct AnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            LinearGradient(
                colors: [Color.indigo, Color.purple, Color.blue],
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .opacity(0.22)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    HomeView()
}
