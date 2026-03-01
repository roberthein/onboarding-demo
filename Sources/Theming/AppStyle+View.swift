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
    public func applyLargeTitleStyle(theme: Theme) {
        let font = theme.font.largeTitle
        let color = theme.color.textPrimary
        let kern = theme.textStyle.largeTitleKern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.textStyle.largeTitleLineHeightMultiple
        paragraphStyle.alignment = .center
        attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: font,
            .foregroundColor: color,
            .kern: kern,
            .paragraphStyle: paragraphStyle
        ])
    }

    public func applyTitleStyle(theme: Theme) {
        font = theme.font.title1
        textColor = theme.color.textPrimary
    }

    public func applyTitle2Style(theme: Theme) {
        applyTitle2Style(theme: theme, opacity: 1)
    }

    public func applyTitle2StyleSubdued(theme: Theme, opacity: CGFloat = 0.6) {
        applyTitle2Style(theme: theme, opacity: opacity)
    }

    private func applyTitle2Style(theme: Theme, opacity: CGFloat) {
        let font = theme.font.title2
        let color = theme.color.textPrimary.withAlphaComponent(opacity)
        let kern = theme.textStyle.title2Kern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.alignment = .center
        attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: font,
            .foregroundColor: color,
            .kern: kern,
            .paragraphStyle: paragraphStyle
        ])
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

    public func applyAccoladeTitleStyle(theme: Theme) {
        let font = theme.font.accoladeTitle
        let color = theme.color.textPrimary
        let kern = theme.textStyle.accoladeTitleKern
        attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: font,
            .foregroundColor: color,
            .kern: kern
        ])
    }

    public func applyAccoladeSubtitleStyle(theme: Theme) {
        let font = theme.font.accoladeSubtitle
        let color = theme.color.textPrimary
        let kern = theme.textStyle.accoladeSubtitleKern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.textStyle.accoladeSubtitleLineHeightMultiple
        attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: font,
            .foregroundColor: color,
            .kern: kern,
            .paragraphStyle: paragraphStyle
        ])
    }

    public func applyIconStyle(theme: Theme) {
        font = .systemFont(ofSize: theme.icon.accoladeEmoji, weight: .regular)
    }

    public func applyDebugStyle(theme: Theme) {
        font = theme.font.monospaced
        textColor = theme.color.debugOverlayText
    }
}
