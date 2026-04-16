import SwiftUI

enum Theme {
    static let backgroundTop = Color(red: 0.08, green: 0.11, blue: 0.16)
    static let backgroundBottom = Color(red: 0.02, green: 0.04, blue: 0.07)
    static let card = Color.white.opacity(0.08)
    static let cardStrong = Color.white.opacity(0.14)
    static let outline = Color.white.opacity(0.12)
    static let accent = Color(red: 0.43, green: 0.79, blue: 0.65)
    static let accentWarm = Color(red: 0.97, green: 0.69, blue: 0.37)
    static let accentCool = Color(red: 0.45, green: 0.67, blue: 0.98)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textMuted = Color.white.opacity(0.48)
}

struct CardSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Theme.outline, lineWidth: 1)
            )
    }
}

extension View {
    func cardSurface() -> some View {
        modifier(CardSurface())
    }
}
