import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ruleCard(
                    icon: "1.circle.fill",
                    title: "配置フェーズ",
                    description: "X と O が交互に空いているマスへコマを置きます。お互い3個ずつ置き終わるまで続きます。"
                )
                ruleCard(
                    icon: "2.circle.fill",
                    title: "移動フェーズ",
                    description: "全員が3個置き終えたら、以降は新しく置く代わりに自分のコマを1つ選び、隣接する空いているマスへ移動させます。"
                )
                ruleCard(
                    icon: "checkmark.seal.fill",
                    title: "勝利条件",
                    description: "縦・横・斜めのいずれか一列に、自分のコマ3つを揃えると勝ちです。"
                )
                ruleCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "動けなくなったら",
                    description: "移動フェーズで自分のコマがどこにも動かせなくなった場合、その時点で相手の勝ちになります。"
                )
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("遊び方")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func ruleCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
}
