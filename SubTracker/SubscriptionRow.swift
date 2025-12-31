import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription
    let highlight: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(subscription.category.color.opacity(subscription.isActive ? 1.0 : 0.35))
                .frame(width: 36, height: 36)
                .background(subscription.category.color.opacity(0.16), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                highlightedName(subscription.name, query: highlight)
                    .font(.headline)
                Text("\(subscription.category.displayName) • \(subscription.cycle.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.formattedAmount)
                    .font(.headline)
                Text(subscription.nextRenewal.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "tr_TR"))))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func highlightedName(_ text: String, query: String) -> Text {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Text(text) }
        let lowerText = text.lowercased()
        let lowerQuery = trimmed.lowercased()
        guard let range = lowerText.range(of: lowerQuery) else { return Text(text) }
        let startIndex = range.lowerBound
        let endIndex = range.upperBound
        let prefix = String(text[..<startIndex])
        let match = String(text[startIndex..<endIndex])
        let suffix = String(text[endIndex...])
        return Text(prefix) + Text(match).bold() + Text(suffix)
    }
}
