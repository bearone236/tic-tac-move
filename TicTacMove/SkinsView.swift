import SwiftUI

struct SkinsView: View {
    @ObservedObject private var progress = ProgressStore.shared

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("通算 \(progress.totalWins) 勝")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ProgressStore.skins) { skin in
                        SkinCard(skin: skin, progress: progress)
                            .onTapGesture {
                                guard progress.isUnlocked(skin) else { return }
                                withAnimation { progress.selectSkin(skin) }
                            }
                    }
                }
            }
            .padding(20)
        }
        .background(AmbientBackground())
        .navigationTitle("スキン")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

private struct SkinCard: View {
    let skin: Skin
    @ObservedObject var progress: ProgressStore

    private var unlocked: Bool { progress.isUnlocked(skin) }
    private var selected: Bool { progress.selectedSkinID == skin.id }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                PieceGlyph(player: .x, style: skin.style, color: skin.xColor)
                    .frame(width: 40, height: 40)
                PieceGlyph(player: .o, style: skin.style, color: skin.oColor)
                    .frame(width: 40, height: 40)
            }
            .opacity(unlocked ? 1 : 0.25)

            Text(skin.name)
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            if unlocked {
                Text(selected ? "使用中" : "タップで選択")
                    .font(.caption)
                    .foregroundStyle(selected ? Theme.accent : .white.opacity(0.5))
            } else {
                Label("\(skin.requiredWins)勝で解放", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(selected ? Theme.accent : Theme.cardStroke, lineWidth: selected ? 2 : 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        SkinsView()
    }
}
