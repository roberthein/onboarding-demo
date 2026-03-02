import UIKit

private func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let base = UIFont.systemFont(ofSize: size, weight: weight)
    guard let roundedDesc = base.fontDescriptor.withDesign(.rounded) else { return base }
    return UIFont(descriptor: roundedDesc, size: 0)
}

public enum AppStyle {

    public enum Font {
        public enum Figma {
            public static let largeTitle = UIFont(name: "SFProDisplay-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
            public static let title1 = UIFont.systemFont(ofSize: 28, weight: .heavy)
            public static let title2 = UIFont(name: "SFProDisplay-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular)
            public static let headline = UIFont.systemFont(ofSize: 18, weight: .bold)
            public static let body = UIFont.systemFont(ofSize: 16, weight: .medium)
            public static let accoladeTitle = UIFont(name: "SFProDisplay-Semibold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .semibold)
            public static let accoladeSubtitle = UIFont(name: "Avenir-Book", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
            public static let caption = UIFont.systemFont(ofSize: 13, weight: .medium)
            public static let monospaced = UIFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        }

        public enum Experimental {
            public static let largeTitle = roundedFont(size: 38, weight: .bold)
            public static let title1 = roundedFont(size: 32, weight: .bold)
            public static let title2 = roundedFont(size: 22, weight: .medium)
            public static let headline = roundedFont(size: 20, weight: .semibold)
            public static let body = roundedFont(size: 17, weight: .regular)
            public static let accoladeTitle = roundedFont(size: 14, weight: .semibold)
            public static let accoladeSubtitle = roundedFont(size: 14, weight: .regular)
            public static let caption = roundedFont(size: 14, weight: .medium)
            public static let monospaced = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }

    public enum Color {
        private static func color(named name: String) -> UIColor {
            UIColor(named: name, in: Bundle.main, compatibleWith: nil) ?? UIColor.black
        }

        public enum Figma {
            public static var primaryBackground: UIColor { color(named: "Figma/PrimaryBackground") }
            public static var gradientPrimary: UIColor { color(named: "Figma/GradientPrimary") }
            public static var gradientSecondary: UIColor { color(named: "Figma/GradientSecondary") }
            public static var surface: UIColor { color(named: "Figma/Surface") }
            public static var textPrimary: UIColor { color(named: "Figma/TextPrimary") }
            public static var textSecondary: UIColor { color(named: "Figma/TextSecondary") }
            public static var accent: UIColor { color(named: "Figma/AccentColor") }
            public static var primaryTint: UIColor { accent }
            public static var secondaryTint: UIColor { color(named: "Figma/SecondaryTint") }
            public static var debugOverlayBackground: UIColor { color(named: "Figma/DebugOverlayBackground") }
            public static var debugOverlayText: UIColor { color(named: "Figma/DebugOverlayText") }
            public static var onAccent: UIColor { color(named: "Figma/OnAccent") }
        }

        public enum Experimental {
            public static var primaryBackground: UIColor { color(named: "Experimental/PrimaryBackground") }
            public static var gradientSecondary: UIColor { color(named: "Experimental/GradientSecondary") }
            public static var surface: UIColor { color(named: "Experimental/Surface") }
            public static var textPrimary: UIColor { color(named: "Experimental/TextPrimary") }
            public static var textSecondary: UIColor { color(named: "Experimental/TextSecondary") }
            public static var accent: UIColor { color(named: "Experimental/AccentColor") }
            public static var primaryTint: UIColor { accent }
            public static var secondaryTint: UIColor { color(named: "Experimental/SecondaryTint") }
            public static var debugOverlayBackground: UIColor { color(named: "Experimental/DebugOverlayBackground") }
            public static var debugOverlayText: UIColor { color(named: "Experimental/DebugOverlayText") }
            public static var onAccent: UIColor { color(named: "Experimental/OnAccent") }
        }
    }

    public enum Margin {
        public enum Figma {
            public static let outer: CGFloat = 16
            public static let inner: CGFloat = 8
            public static var outerDouble: CGFloat { outer * 2 }
            public static var outerHalf: CGFloat { outer / 2 }
            public static var innerDouble: CGFloat { inner * 2 }
            public static var innerHalf: CGFloat { inner / 2 }
        }

        public enum Experimental {
            public static let outer: CGFloat = 24
            public static let inner: CGFloat = 12
            public static var outerDouble: CGFloat { outer * 2 }
            public static var outerHalf: CGFloat { outer / 2 }
            public static var innerDouble: CGFloat { inner * 2 }
            public static var innerHalf: CGFloat { inner / 2 }
        }
    }

    public enum Spacing {
        public enum Figma {
            public static let section: CGFloat = 24
            public static let item: CGFloat = 12
            public static let content: CGFloat = 32
            public static var sectionHalf: CGFloat { section / 2 }
            public static var itemHalf: CGFloat { item / 2 }
        }

        public enum Experimental {
            public static let section: CGFloat = 32
            public static let item: CGFloat = 16
            public static let content: CGFloat = 40
            public static var sectionHalf: CGFloat { section / 2 }
            public static var itemHalf: CGFloat { item / 2 }
        }
    }

    public enum Radius {
        public enum Figma {
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 12
            public static let large: CGFloat = 20
        }

        public enum Experimental {
            public static let small: CGFloat = 16
            public static let medium: CGFloat = 24
            public static let large: CGFloat = 32
        }
    }

    public enum Layout {
        public enum Figma {
            public static let buttonHeight: CGFloat = 44
            public static let footerButtonHeight: CGFloat = 44
            public static let footerBottomPadding: CGFloat = 24
            public static let footerSlideOffset: CGFloat = 40
            public static let footerHorizontalPadding: CGFloat = 32
            public static let footerWelcomeLabelTopMargin: CGFloat = 16
            public static let footerWelcomeLabelMarginToButton: CGFloat = 24
            public static let footerWelcomeLabelHeight: CGFloat = 22
            public static let footerPageIndicatorTopMargin: CGFloat = 16
            public static let footerPageIndicatorDotSize: CGFloat = 6
            public static let footerPageIndicatorDotSpacing: CGFloat = 8
            public static let footerPageIndicatorInactiveAlpha: CGFloat = 0.5
            public static let debugOverlayMargin: CGFloat = 10
            public static let debugOverlayPadding: CGFloat = 8
        }

        public enum Experimental {
            public static let buttonHeight: CGFloat = 52
            public static let footerButtonHeight: CGFloat = 56
            public static let footerBottomPadding: CGFloat = 32
            public static let footerSlideOffset: CGFloat = 48
            public static let footerHorizontalPadding: CGFloat = 28
            public static let footerWelcomeLabelTopMargin: CGFloat = 20
            public static let footerWelcomeLabelMarginToButton: CGFloat = 28
            public static let footerWelcomeLabelHeight: CGFloat = 24
            public static let footerPageIndicatorTopMargin: CGFloat = 20
            public static let footerPageIndicatorDotSize: CGFloat = 8
            public static let footerPageIndicatorDotSpacing: CGFloat = 10
            public static let footerPageIndicatorInactiveAlpha: CGFloat = 0.5
            public static let debugOverlayMargin: CGFloat = 12
            public static let debugOverlayPadding: CGFloat = 10
        }
    }

    public enum SkillLevelPicker {
        public enum Figma {
            public static let itemHeight: CGFloat = 48
            public static let spacing: CGFloat = 8
            public static let paddingVertical: CGFloat = 12
            public static let paddingHorizontal: CGFloat = 16
            public static let imageLeadingMargin: CGFloat = 16
            public static let imageTrailingMargin: CGFloat = 16
            public static let font = UIFont.systemFont(ofSize: 17, weight: .regular)
            public static let kern: CGFloat = -0.44
            public static let selectedStrokeWidth: CGFloat = 2
        }

        public enum Experimental {
            public static let itemHeight: CGFloat = 56
            public static let spacing: CGFloat = 12
            public static let paddingVertical: CGFloat = 16
            public static let paddingHorizontal: CGFloat = 20
            public static let imageLeadingMargin: CGFloat = 20
            public static let imageTrailingMargin: CGFloat = 20
            public static let font = roundedFont(size: 18, weight: .medium)
            public static let kern: CGFloat = -0.2
            public static let selectedStrokeWidth: CGFloat = 3
        }
    }

    public enum AccoladeCard {
        public enum Figma {
            public static let centerStackSpacing: CGFloat = 4
            public static let titleRowSpacing: CGFloat = 2
            public static let mainStackSpacing: CGFloat = -12
            public static let iconSize: CGFloat = 16
        }

        public enum Experimental {
            public static let centerStackSpacing: CGFloat = 8
            public static let titleRowSpacing: CGFloat = 6
            public static let mainStackSpacing: CGFloat = 4
            public static let iconSize: CGFloat = 20
        }
    }

    public enum MainContent {
        public enum Figma {
            public static let verticalOffsetStart: CGFloat = 320
            public static let verticalOffsetEnd: CGFloat = 50
            public static let appearPhaseEndY: CGFloat = 135
            public static let scrollPhaseStartY: CGFloat = 320
            public static let expandableTranslationY: CGFloat = 100
            public static let expandableLabelTranslationY: CGFloat = 100
            public static let labelScaleStart: CGFloat = 0.5
            public static let labelScaleStartFactor: CGFloat = 0.6
        }

        public enum Experimental {
            public static let verticalOffsetStart: CGFloat = 320
            public static let verticalOffsetEnd: CGFloat = 50
            public static let appearPhaseEndY: CGFloat = 135
            public static let scrollPhaseStartY: CGFloat = 320
            public static let expandableTranslationY: CGFloat = 100
            public static let expandableLabelTranslationY: CGFloat = 100
            public static let labelScaleStart: CGFloat = 0.5
            public static let labelScaleStartFactor: CGFloat = 0.6
        }
    }

    public enum SkillPickerFace {
        public enum Figma {
            public static let bounceDuration: TimeInterval = 0.6
            public static let bounceDamping: CGFloat = 0.45
            public static let bounceVelocity: CGFloat = 0.8
            public static let rotationAngle: CGFloat = .pi / 18
        }

        public enum Experimental {
            public static let bounceDuration: TimeInterval = 0.8
            public static let bounceDamping: CGFloat = 0.5
            public static let bounceVelocity: CGFloat = 1.2
            public static let rotationAngle: CGFloat = .pi / 12
        }
    }

    public enum AppearAnimation {
        public enum Figma {
            public static let footerStartT: CGFloat = 0.25
            public static let footerEndT: CGFloat = 1
        }

        public enum Experimental {
            public static let footerStartT: CGFloat = 0.2
            public static let footerEndT: CGFloat = 1
        }
    }

    public enum TextStyle {
        public enum Figma {
            public static let largeTitleKern: CGFloat = 34 * 0.02
            public static let largeTitleLineHeightMultiple: CGFloat = 38 / 34
            public static let title2Kern: CGFloat = 22 * 0.02
            public static let accoladeTitleKern: CGFloat = 13 * 0.02
            public static let accoladeSubtitleKern: CGFloat = 13 * 0.02
            public static let accoladeSubtitleLineHeightMultiple: CGFloat = 1

            public static let continueButtonLineHeightMultiple: CGFloat = 1
        }

        public enum Experimental {
            public static let largeTitleKern: CGFloat = 38 * 0.03
            public static let largeTitleLineHeightMultiple: CGFloat = 1.2
            public static let title2Kern: CGFloat = 22 * 0.03
            public static let accoladeTitleKern: CGFloat = 14 * 0.02
            public static let accoladeSubtitleKern: CGFloat = 14 * 0.02
            public static let accoladeSubtitleLineHeightMultiple: CGFloat = 1.15

            public static let continueButtonLineHeightMultiple: CGFloat = 1.1
        }
    }

    public enum ContinueButton {
        public enum Figma {
            public static let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            public static let titleKern: CGFloat = -0.44
            public static let cornerRadius: CGFloat = 14
            public static let disabledAlpha: CGFloat = 0.3
        }

        public enum Experimental {
            public static let titleFont = roundedFont(size: 19, weight: .bold)
            public static let titleKern: CGFloat = -0.2
            public static let cornerRadius: CGFloat = 28
            public static let disabledAlpha: CGFloat = 0.4
        }
    }

    public enum Icon {
        public enum Figma {
            public static let accoladeEmoji: CGFloat = 44
            public static let large: CGFloat = 48
            public static let standard: CGFloat = 24
            public static let small: CGFloat = 16
        }

        public enum Experimental {
            public static let accoladeEmoji: CGFloat = 52
            public static let large: CGFloat = 56
            public static let standard: CGFloat = 28
            public static let small: CGFloat = 18
        }
    }

    public enum Motion {
        public enum Figma {
            public static let duration: TimeInterval = 0.4
            public static let springDamping: CGFloat = 0.8
        }

        public enum Experimental {
            public static let duration: TimeInterval = 0.3
            public static let springDamping: CGFloat = 0.75
        }
    }
}
