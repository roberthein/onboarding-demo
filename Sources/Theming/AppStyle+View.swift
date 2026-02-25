import UIKit

extension UIView {
    public func applySmallCornerRadius(theme: Theme) {
        layer.cornerRadius = theme.radius.small
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }

    public func applyMediumCornerRadius(theme: Theme) {
        layer.cornerRadius = theme.radius.medium
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }

    public func applyLargeCornerRadius(theme: Theme) {
        layer.cornerRadius = theme.radius.large
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
}

extension UILabel {
    public func applyTitleStyle(theme: Theme) {
        font = theme.font.title1
        textColor = theme.color.textPrimary
    }

    public func applyHeadlineStyle(theme: Theme) {
        font = theme.font.headline
        textColor = theme.color.textPrimary
    }

    public func applyBodyStyle(theme: Theme) {
        font = theme.font.body
        textColor = theme.color.textPrimary
    }

    public func applySubtitleStyle(theme: Theme) {
        font = theme.font.body
        textColor = theme.color.textSecondary
    }

    public func applyCaptionStyle(theme: Theme) {
        font = theme.font.caption
        textColor = theme.color.textSecondary
    }

    public func applyIconStyle(theme: Theme) {
        font = .systemFont(ofSize: theme.icon.accoladeEmoji, weight: .regular)
    }

    public func applyDebugStyle(theme: Theme) {
        font = theme.font.monospaced
        textColor = theme.color.debugOverlayText
    }
}
