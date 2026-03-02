import UIKit

public enum Theme: String, CaseIterable, Sendable {
    case figma
    case experimental

    var isExperimental: Bool {
        self == .experimental
    }
}

extension Theme {
    public var id: String { rawValue }
    public static var fallback: Theme { .figma }
}

public struct ThemeFonts: Sendable {
    let theme: Theme

    public var largeTitle: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.largeTitle
        case .experimental: return AppStyle.Font.Experimental.largeTitle
        }
    }

    public var title1: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.title1
        case .experimental: return AppStyle.Font.Experimental.title1
        }
    }

    public var title2: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.title2
        case .experimental: return AppStyle.Font.Experimental.title2
        }
    }

    public var accoladeTitle: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.accoladeTitle
        case .experimental: return AppStyle.Font.Experimental.accoladeTitle
        }
    }

    public var accoladeSubtitle: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.accoladeSubtitle
        case .experimental: return AppStyle.Font.Experimental.accoladeSubtitle
        }
    }

    public var headline: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.headline
        case .experimental: return AppStyle.Font.Experimental.headline
        }
    }

    public var body: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.body
        case .experimental: return AppStyle.Font.Experimental.body
        }
    }

    public var caption: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.caption
        case .experimental: return AppStyle.Font.Experimental.caption
        }
    }

    public var monospaced: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.monospaced
        case .experimental: return AppStyle.Font.Experimental.monospaced
        }
    }
}

extension Theme {
    public var font: ThemeFonts { ThemeFonts(theme: self) }
}

public struct ThemeColors: Sendable {
    let theme: Theme

    public var primaryBackground: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.primaryBackground
        case .experimental: return AppStyle.Color.Experimental.primaryBackground
        }
    }

    public var gradientPrimaryBackground: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.gradientPrimary
        case .experimental: return Self.blend(
            AppStyle.Color.Experimental.gradientSecondary,
            AppStyle.Color.Experimental.accent,
            factor: 0.3
        )
        }
    }

    private static func blend(_ first: UIColor, _ second: UIColor, factor: CGFloat) -> UIColor {
        let f = min(max(factor, 0), 1)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        first.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        second.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: (1 - f) * r1 + f * r2,
            green: (1 - f) * g1 + f * g2,
            blue: (1 - f) * b1 + f * b2,
            alpha: (1 - f) * a1 + f * a2
        )
    }

    public var gradientSecondaryBackground: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.gradientSecondary
        case .experimental: return AppStyle.Color.Experimental.gradientSecondary
        }
    }

    public var surface: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.surface
        case .experimental: return AppStyle.Color.Experimental.surface
        }
    }

    public var textPrimary: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.textPrimary
        case .experimental: return AppStyle.Color.Experimental.textPrimary
        }
    }

    public var textSecondary: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.textSecondary
        case .experimental: return AppStyle.Color.Experimental.textSecondary
        }
    }

    public var accent: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.accent
        case .experimental: return AppStyle.Color.Experimental.accent
        }
    }

    public var primaryTint: UIColor { accent }

    public var secondaryTint: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.secondaryTint
        case .experimental: return AppStyle.Color.Experimental.secondaryTint
        }
    }

    public var debugOverlayBackground: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.debugOverlayBackground
        case .experimental: return AppStyle.Color.Experimental.debugOverlayBackground
        }
    }

    public var debugOverlayText: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.debugOverlayText
        case .experimental: return AppStyle.Color.Experimental.debugOverlayText
        }
    }

    public var onAccent: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.onAccent
        case .experimental: return AppStyle.Color.Experimental.onAccent
        }
    }
}

extension Theme {
    public var color: ThemeColors { ThemeColors(theme: self) }
}

public struct ThemeMargins: Sendable {
    let theme: Theme

    public var outer: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.outer
        case .experimental: return AppStyle.Margin.Experimental.outer
        }
    }

    public var inner: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.inner
        case .experimental: return AppStyle.Margin.Experimental.inner
        }
    }

    public var outerHalf: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.outerHalf
        case .experimental: return AppStyle.Margin.Experimental.outerHalf
        }
    }

    public var innerHalf: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.innerHalf
        case .experimental: return AppStyle.Margin.Experimental.innerHalf
        }
    }

    public var outerDouble: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.outerDouble
        case .experimental: return AppStyle.Margin.Experimental.outerDouble
        }
    }

    public var innerDouble: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.innerDouble
        case .experimental: return AppStyle.Margin.Experimental.innerDouble
        }
    }
}

extension Theme {
    public var margin: ThemeMargins { ThemeMargins(theme: self) }
}

public struct ThemeSpacing: Sendable {
    let theme: Theme

    public var section: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.section
        case .experimental: return AppStyle.Spacing.Experimental.section
        }
    }

    public var item: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.item
        case .experimental: return AppStyle.Spacing.Experimental.item
        }
    }

    public var content: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.content
        case .experimental: return AppStyle.Spacing.Experimental.content
        }
    }

    public var sectionHalf: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.sectionHalf
        case .experimental: return AppStyle.Spacing.Experimental.sectionHalf
        }
    }

    public var itemHalf: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.itemHalf
        case .experimental: return AppStyle.Spacing.Experimental.itemHalf
        }
    }

    public var xs: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.innerHalf
        case .experimental: return AppStyle.Margin.Experimental.innerHalf
        }
    }

    public var sm: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.inner
        case .experimental: return AppStyle.Margin.Experimental.inner
        }
    }

    public var md: CGFloat {
        switch theme {
        case .figma: return AppStyle.Margin.Figma.outer
        case .experimental: return AppStyle.Margin.Experimental.outer
        }
    }

    public var lg: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.section
        case .experimental: return AppStyle.Spacing.Experimental.section
        }
    }

    public var xl: CGFloat {
        switch theme {
        case .figma: return AppStyle.Spacing.Figma.content
        case .experimental: return AppStyle.Spacing.Experimental.content
        }
    }
}

extension Theme {
    public var spacing: ThemeSpacing { ThemeSpacing(theme: self) }
}

public struct ThemeRadius: Sendable {
    let theme: Theme

    public var small: CGFloat {
        switch theme {
        case .figma: return AppStyle.Radius.Figma.small
        case .experimental: return AppStyle.Radius.Experimental.small
        }
    }

    public var medium: CGFloat {
        switch theme {
        case .figma: return AppStyle.Radius.Figma.medium
        case .experimental: return AppStyle.Radius.Experimental.medium
        }
    }

    public var large: CGFloat {
        switch theme {
        case .figma: return AppStyle.Radius.Figma.large
        case .experimental: return AppStyle.Radius.Experimental.large
        }
    }
}

extension Theme {
    public var radius: ThemeRadius { ThemeRadius(theme: self) }
}

public struct ThemeLayout: Sendable {
    let theme: Theme

    public var buttonHeight: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.buttonHeight
        case .experimental: return AppStyle.Layout.Experimental.buttonHeight
        }
    }

    public var debugOverlayMargin: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.debugOverlayMargin
        case .experimental: return AppStyle.Layout.Experimental.debugOverlayMargin
        }
    }

    public var debugOverlayPadding: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.debugOverlayPadding
        case .experimental: return AppStyle.Layout.Experimental.debugOverlayPadding
        }
    }

    public var footerButtonHeight: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerButtonHeight
        case .experimental: return AppStyle.Layout.Experimental.footerButtonHeight
        }
    }

    public var footerBottomPadding: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerBottomPadding
        case .experimental: return AppStyle.Layout.Experimental.footerBottomPadding
        }
    }

    public var footerHorizontalPadding: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerHorizontalPadding
        case .experimental: return AppStyle.Layout.Experimental.footerHorizontalPadding
        }
    }

    public var footerSlideOffset: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerSlideOffset
        case .experimental: return AppStyle.Layout.Experimental.footerSlideOffset
        }
    }

    public var footerWelcomeLabelTopMargin: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerWelcomeLabelTopMargin
        case .experimental: return AppStyle.Layout.Experimental.footerWelcomeLabelTopMargin
        }
    }

    public var footerWelcomeLabelHeight: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerWelcomeLabelHeight
        case .experimental: return AppStyle.Layout.Experimental.footerWelcomeLabelHeight
        }
    }

    public var footerWelcomeLabelMarginToButton: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerWelcomeLabelMarginToButton
        case .experimental: return AppStyle.Layout.Experimental.footerWelcomeLabelMarginToButton
        }
    }

    public var footerPageIndicatorTopMargin: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerPageIndicatorTopMargin
        case .experimental: return AppStyle.Layout.Experimental.footerPageIndicatorTopMargin
        }
    }

    public var footerPageIndicatorDotSize: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerPageIndicatorDotSize
        case .experimental: return AppStyle.Layout.Experimental.footerPageIndicatorDotSize
        }
    }

    public var footerPageIndicatorDotSpacing: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerPageIndicatorDotSpacing
        case .experimental: return AppStyle.Layout.Experimental.footerPageIndicatorDotSpacing
        }
    }

    public var footerPageIndicatorInactiveAlpha: CGFloat {
        switch theme {
        case .figma: return AppStyle.Layout.Figma.footerPageIndicatorInactiveAlpha
        case .experimental: return AppStyle.Layout.Experimental.footerPageIndicatorInactiveAlpha
        }
    }

    public var footerTotalHeight: CGFloat {
        footerWelcomeLabelTopMargin + footerWelcomeLabelHeight + footerWelcomeLabelMarginToButton +
        footerButtonHeight + footerPageIndicatorTopMargin + footerPageIndicatorDotSize
    }
}

extension Theme {
    public var layout: ThemeLayout { ThemeLayout(theme: self) }
}

public struct ThemeTextStyle: Sendable {
    let theme: Theme

    public var largeTitleKern: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.largeTitleKern
        case .experimental: return AppStyle.TextStyle.Experimental.largeTitleKern
        }
    }

    public var largeTitleLineHeightMultiple: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.largeTitleLineHeightMultiple
        case .experimental: return AppStyle.TextStyle.Experimental.largeTitleLineHeightMultiple
        }
    }

    public var title2Kern: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.title2Kern
        case .experimental: return AppStyle.TextStyle.Experimental.title2Kern
        }
    }

    public var accoladeTitleKern: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.accoladeTitleKern
        case .experimental: return AppStyle.TextStyle.Experimental.accoladeTitleKern
        }
    }

    public var accoladeSubtitleKern: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.accoladeSubtitleKern
        case .experimental: return AppStyle.TextStyle.Experimental.accoladeSubtitleKern
        }
    }

    public var accoladeSubtitleLineHeightMultiple: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.accoladeSubtitleLineHeightMultiple
        case .experimental: return AppStyle.TextStyle.Experimental.accoladeSubtitleLineHeightMultiple
        }
    }

    public var continueButtonLineHeightMultiple: CGFloat {
        switch theme {
        case .figma: return AppStyle.TextStyle.Figma.continueButtonLineHeightMultiple
        case .experimental: return AppStyle.TextStyle.Experimental.continueButtonLineHeightMultiple
        }
    }
}

extension Theme {
    public var textStyle: ThemeTextStyle { ThemeTextStyle(theme: self) }
}

public struct ThemeSkillLevelPicker: Sendable {
    let theme: Theme

    public var itemHeight: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.itemHeight
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.itemHeight
        }
    }

    public var spacing: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.spacing
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.spacing
        }
    }

    public var paddingVertical: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.paddingVertical
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.paddingVertical
        }
    }

    public var paddingHorizontal: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.paddingHorizontal
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.paddingHorizontal
        }
    }

    public var imageLeadingMargin: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.imageLeadingMargin
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.imageLeadingMargin
        }
    }

    public var imageTrailingMargin: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.imageTrailingMargin
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.imageTrailingMargin
        }
    }

    public var font: UIFont {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.font
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.font
        }
    }

    public var kern: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.kern
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.kern
        }
    }

    public var selectedStrokeWidth: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillLevelPicker.Figma.selectedStrokeWidth
        case .experimental: return AppStyle.SkillLevelPicker.Experimental.selectedStrokeWidth
        }
    }
}

extension Theme {
    public var skillLevelPicker: ThemeSkillLevelPicker { ThemeSkillLevelPicker(theme: self) }
}

public struct ThemeAccoladeCard: Sendable {
    let theme: Theme

    public var centerStackSpacing: CGFloat {
        switch theme {
        case .figma: return AppStyle.AccoladeCard.Figma.centerStackSpacing
        case .experimental: return AppStyle.AccoladeCard.Experimental.centerStackSpacing
        }
    }

    public var titleRowSpacing: CGFloat {
        switch theme {
        case .figma: return AppStyle.AccoladeCard.Figma.titleRowSpacing
        case .experimental: return AppStyle.AccoladeCard.Experimental.titleRowSpacing
        }
    }

    public var mainStackSpacing: CGFloat {
        switch theme {
        case .figma: return AppStyle.AccoladeCard.Figma.mainStackSpacing
        case .experimental: return AppStyle.AccoladeCard.Experimental.mainStackSpacing
        }
    }

    public var iconSize: CGFloat {
        switch theme {
        case .figma: return AppStyle.AccoladeCard.Figma.iconSize
        case .experimental: return AppStyle.AccoladeCard.Experimental.iconSize
        }
    }
}

extension Theme {
    public var accoladeCard: ThemeAccoladeCard { ThemeAccoladeCard(theme: self) }
}

public struct ThemeMainContent: Sendable {
    let theme: Theme

    public var verticalOffsetStart: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.verticalOffsetStart
        case .experimental: return AppStyle.MainContent.Experimental.verticalOffsetStart
        }
    }

    public var verticalOffsetEnd: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.verticalOffsetEnd
        case .experimental: return AppStyle.MainContent.Experimental.verticalOffsetEnd
        }
    }

    public var appearPhaseEndY: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.appearPhaseEndY
        case .experimental: return AppStyle.MainContent.Experimental.appearPhaseEndY
        }
    }

    public var scrollPhaseStartY: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.scrollPhaseStartY
        case .experimental: return AppStyle.MainContent.Experimental.scrollPhaseStartY
        }
    }

    public var expandableTranslationY: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.expandableTranslationY
        case .experimental: return AppStyle.MainContent.Experimental.expandableTranslationY
        }
    }

    public var expandableLabelTranslationY: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.expandableLabelTranslationY
        case .experimental: return AppStyle.MainContent.Experimental.expandableLabelTranslationY
        }
    }

    public var labelScaleStart: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.labelScaleStart
        case .experimental: return AppStyle.MainContent.Experimental.labelScaleStart
        }
    }

    public var labelScaleStartFactor: CGFloat {
        switch theme {
        case .figma: return AppStyle.MainContent.Figma.labelScaleStartFactor
        case .experimental: return AppStyle.MainContent.Experimental.labelScaleStartFactor
        }
    }
}

extension Theme {
    public var mainContent: ThemeMainContent { ThemeMainContent(theme: self) }
}

public struct ThemeSkillPickerFace: Sendable {
    let theme: Theme

    public var bounceDuration: TimeInterval {
        switch theme {
        case .figma: return AppStyle.SkillPickerFace.Figma.bounceDuration
        case .experimental: return AppStyle.SkillPickerFace.Experimental.bounceDuration
        }
    }

    public var bounceDamping: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillPickerFace.Figma.bounceDamping
        case .experimental: return AppStyle.SkillPickerFace.Experimental.bounceDamping
        }
    }

    public var bounceVelocity: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillPickerFace.Figma.bounceVelocity
        case .experimental: return AppStyle.SkillPickerFace.Experimental.bounceVelocity
        }
    }

    public var rotationAngle: CGFloat {
        switch theme {
        case .figma: return AppStyle.SkillPickerFace.Figma.rotationAngle
        case .experimental: return AppStyle.SkillPickerFace.Experimental.rotationAngle
        }
    }
}

extension Theme {
    public var skillPickerFace: ThemeSkillPickerFace { ThemeSkillPickerFace(theme: self) }
}

public struct ThemeAppearAnimation: Sendable {
    let theme: Theme

    public var footerStartT: CGFloat {
        switch theme {
        case .figma: return AppStyle.AppearAnimation.Figma.footerStartT
        case .experimental: return AppStyle.AppearAnimation.Experimental.footerStartT
        }
    }

    public var footerEndT: CGFloat {
        switch theme {
        case .figma: return AppStyle.AppearAnimation.Figma.footerEndT
        case .experimental: return AppStyle.AppearAnimation.Experimental.footerEndT
        }
    }
}

extension Theme {
    public var appearAnimation: ThemeAppearAnimation { ThemeAppearAnimation(theme: self) }
}

public struct ThemeSkillPickerPage: Sendable {
    let theme: Theme

    public var horizontalMargin: CGFloat {
        theme.layout.footerHorizontalPadding
    }
}

extension Theme {
    public var skillPickerPage: ThemeSkillPickerPage { ThemeSkillPickerPage(theme: self) }
}


public struct ThemeContinueButton: Sendable {
    let theme: Theme

    public var titleFont: UIFont {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.titleFont
        case .experimental: return AppStyle.ContinueButton.Experimental.titleFont
        }
    }

    public var titleKern: CGFloat {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.titleKern
        case .experimental: return AppStyle.ContinueButton.Experimental.titleKern
        }
    }

    public var cornerRadius: CGFloat {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.cornerRadius
        case .experimental: return AppStyle.ContinueButton.Experimental.cornerRadius
        }
    }

    public var disabledAlpha: CGFloat {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.disabledAlpha
        case .experimental: return AppStyle.ContinueButton.Experimental.disabledAlpha
        }
    }
}

extension Theme {
    public var continueButton: ThemeContinueButton { ThemeContinueButton(theme: self) }
}

public struct ThemeIcon: Sendable {
    let theme: Theme

    public var accoladeEmoji: CGFloat {
        switch theme {
        case .figma: return AppStyle.Icon.Figma.accoladeEmoji
        case .experimental: return AppStyle.Icon.Experimental.accoladeEmoji
        }
    }

    public var large: CGFloat {
        switch theme {
        case .figma: return AppStyle.Icon.Figma.large
        case .experimental: return AppStyle.Icon.Experimental.large
        }
    }

    public var standard: CGFloat {
        switch theme {
        case .figma: return AppStyle.Icon.Figma.standard
        case .experimental: return AppStyle.Icon.Experimental.standard
        }
    }

    public var small: CGFloat {
        switch theme {
        case .figma: return AppStyle.Icon.Figma.small
        case .experimental: return AppStyle.Icon.Experimental.small
        }
    }
}

extension Theme {
    public var icon: ThemeIcon { ThemeIcon(theme: self) }
}

public struct ThemeMotion: Sendable {
    let theme: Theme

    public var duration: TimeInterval {
        switch theme {
        case .figma: return AppStyle.Motion.Figma.duration
        case .experimental: return AppStyle.Motion.Experimental.duration
        }
    }

    public var springDamping: CGFloat {
        switch theme {
        case .figma: return AppStyle.Motion.Figma.springDamping
        case .experimental: return AppStyle.Motion.Experimental.springDamping
        }
    }
}

extension Theme {
    public var motion: ThemeMotion { ThemeMotion(theme: self) }
}

extension Theme {
    public var background: UIColor { color.primaryBackground }
    public var titleFont: UIFont { font.title1 }
    public var bodyFont: UIFont { font.body }
    public var captionFont: UIFont { font.caption }
    public var headlineFont: UIFont { font.headline }

    public var spacingXS: CGFloat { spacing.xs }
    public var spacingSM: CGFloat { spacing.sm }
    public var spacingMD: CGFloat { spacing.md }
    public var spacingLG: CGFloat { spacing.lg }
    public var spacingXL: CGFloat { spacing.xl }

    public var cornerRadiusSM: CGFloat { radius.small }
    public var cornerRadiusMD: CGFloat { radius.medium }
    public var cornerRadiusLG: CGFloat { radius.large }

    public var animationDuration: TimeInterval { motion.duration }
    public var springDamping: CGFloat { motion.springDamping }
}
