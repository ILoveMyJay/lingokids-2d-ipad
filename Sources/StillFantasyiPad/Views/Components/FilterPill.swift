import SwiftUI

/// Reusable capsule filter pill with a minimum 44pt-friendly tap area.
public struct FilterPill<Value: Equatable>: View {
    public let title: String
    public let value: Value
    @Binding public var selection: Value

    public init(title: String, value: Value, selection: Binding<Value>) {
        self.title = title
        self.value = value
        self._selection = selection
    }

    private var isSelected: Bool {
        selection == value
    }

    public var body: some View {
        Button(action: {
            selection = value
        }) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? Color.biolumMint : Color.darkEmeraldCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : Color.darkEmeraldBorder, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
