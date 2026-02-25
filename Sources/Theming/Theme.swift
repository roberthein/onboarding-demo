import UIKit

public enum Theme: String, CaseIterable, Sendable {
    case figma
    case experimental
}

// MARK: - Theme Identity

extension Theme {
    public var id: String { rawValue }
}

// MARK: - Theme.Font (semantic typography)

public struct ThemeFonts: Sendable {
    let theme: Theme

    public var title1: UIFont {
        switch theme {
        case .figma: return AppStyle.Font.Figma.title1
        case .experimental: return AppStyle.Font.Experimental.title1
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

// MARK: - Theme.Color (semantic colors)

public struct ThemeColors: Sendable {
    let theme: Theme

    public var primaryBackground: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.primaryBackground
        case .experimental: return AppStyle.Color.Experimental.primaryBackground
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

    public var primaryTint: UIColor {
        switch theme {
        case .figma: return AppStyle.Color.Figma.primaryTint
        case .experimental: return AppStyle.Color.Experimental.primaryTint
        }
    }

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

// MARK: - Theme.Margin (semantic margins)

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

// MARK: - Theme.Spacing (semantic spacing)

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

// MARK: - Theme.Radius (semantic corner radii)

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

// MARK: - Theme.Layout (semantic layout dimensions)

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
}

extension Theme {
    public var layout: ThemeLayout { ThemeLayout(theme: self) }
}

// MARK: - Theme.ContinueButton (footer button styling)

public struct ThemeContinueButton: Sendable {
    let theme: Theme

    public var titleFont: UIFont {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.titleFont
        case .experimental: return AppStyle.ContinueButton.Experimental.titleFont
        }
    }

    public var cornerRadius: CGFloat {
        switch theme {
        case .figma: return AppStyle.ContinueButton.Figma.cornerRadius
        case .experimental: return AppStyle.ContinueButton.Experimental.cornerRadius
        }
    }
}

extension Theme {
    public var continueButton: ThemeContinueButton { ThemeContinueButton(theme: self) }
}

// MARK: - Theme.Icon (semantic icon sizes)

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

// MARK: - Theme.Motion (semantic animation values)

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

    public var reducedMotionScale: CGFloat {
        switch theme {
        case .figma: return AppStyle.Motion.Figma.reducedMotionScale
        case .experimental: return AppStyle.Motion.Experimental.reducedMotionScale
        }
    }
}

extension Theme {
    public var motion: ThemeMotion { ThemeMotion(theme: self) }
}

// MARK: - Convenience aliases (backward compatible with existing property names)

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
    public var reducedMotionScale: CGFloat { motion.reducedMotionScale }
}
