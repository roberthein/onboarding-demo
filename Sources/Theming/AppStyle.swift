import UIKit

// MARK: - AppStyle

public enum AppStyle {

    // MARK: Font (absolute typography values per variant)

    public enum Font {
        public enum Figma {
            public static let title1 = UIFont.systemFont(ofSize: 28, weight: .heavy)
            public static let headline = UIFont.systemFont(ofSize: 18, weight: .bold)
            public static let body = UIFont.systemFont(ofSize: 16, weight: .medium)
            public static let caption = UIFont.systemFont(ofSize: 13, weight: .medium)
            public static let monospaced = UIFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        }

        public enum Experimental {
            public static let title1 = UIFont.systemFont(ofSize: 42, weight: .semibold)
            public static let headline = UIFont.systemFont(ofSize: 24, weight: .semibold)
            public static let body = UIFont.systemFont(ofSize: 18, weight: .regular)
            public static let caption = UIFont.systemFont(ofSize: 15, weight: .medium)
            public static let monospaced = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }

    // MARK: Color (absolute color values per variant)

    public enum Color {
        public enum Figma {
            public static let primaryBackground = UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1)
            public static let surface = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            public static let textPrimary = UIColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1)
            public static let textSecondary = UIColor(red: 0.35, green: 0.35, blue: 0.42, alpha: 1)
            public static let accent = UIColor(red: 0.12, green: 0.35, blue: 0.82, alpha: 1)
            public static let primaryTint = UIColor(red: 0.08, green: 0.18, blue: 0.5, alpha: 1)
            public static let secondaryTint = UIColor(red: 0.2, green: 0.28, blue: 0.52, alpha: 1)
            public static let debugOverlayBackground = UIColor(red: 0.2, green: 0.22, blue: 0.28, alpha: 0.92)
            public static let debugOverlayText = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
            public static let onAccent = UIColor.white
        }

        public enum Experimental {
            public static let primaryBackground = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
            public static let surface = UIColor(red: 0.14, green: 0.14, blue: 0.2, alpha: 1)
            public static let textPrimary = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1)
            public static let textSecondary = UIColor(red: 0.55, green: 0.58, blue: 0.68, alpha: 1)
            public static let accent = UIColor(red: 0.45, green: 0.65, blue: 1, alpha: 1)
            public static let primaryTint = UIColor(red: 0.6, green: 0.7, blue: 0.95, alpha: 1)
            public static let secondaryTint = UIColor(red: 0.5, green: 0.55, blue: 0.7, alpha: 1)
            public static let debugOverlayBackground = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.95)
            public static let debugOverlayText = UIColor(red: 0.92, green: 0.93, blue: 0.96, alpha: 1)
            public static let onAccent = UIColor.white
        }
    }

    // MARK: Margin (absolute spacing values per variant)

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
            public static let outer: CGFloat = 20
            public static let inner: CGFloat = 10
            public static var outerDouble: CGFloat { outer * 2 }
            public static var outerHalf: CGFloat { outer / 2 }
            public static var innerDouble: CGFloat { inner * 2 }
            public static var innerHalf: CGFloat { inner / 2 }
        }
    }

    // MARK: Spacing (absolute spacing values per variant)

    public enum Spacing {
        public enum Figma {
            public static let section: CGFloat = 24
            public static let item: CGFloat = 12
            public static let content: CGFloat = 32
            public static var sectionHalf: CGFloat { section / 2 }
            public static var itemHalf: CGFloat { item / 2 }
        }

        public enum Experimental {
            public static let section: CGFloat = 28
            public static let item: CGFloat = 14
            public static let content: CGFloat = 36
            public static var sectionHalf: CGFloat { section / 2 }
            public static var itemHalf: CGFloat { item / 2 }
        }
    }

    // MARK: Radius (absolute corner radius values per variant)

    public enum Radius {
        public enum Figma {
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 12
            public static let large: CGFloat = 20
        }

        public enum Experimental {
            public static let small: CGFloat = 10
            public static let medium: CGFloat = 14
            public static let large: CGFloat = 24
        }
    }

    // MARK: Layout (absolute layout dimensions per variant)

    public enum Layout {
        public enum Figma {
            public static let buttonHeight: CGFloat = 44
            public static let footerButtonHeight: CGFloat = 52
            public static let footerBottomPadding: CGFloat = 24
            public static let footerSlideOffset: CGFloat = 40
            public static let footerHorizontalPadding: CGFloat = 16
            public static let debugOverlayMargin: CGFloat = 10
            public static let debugOverlayPadding: CGFloat = 8
        }

        public enum Experimental {
            public static let buttonHeight: CGFloat = 48
            public static let footerButtonHeight: CGFloat = 56
            public static let footerBottomPadding: CGFloat = 28
            public static let footerSlideOffset: CGFloat = 44
            public static let footerHorizontalPadding: CGFloat = 20
            public static let debugOverlayMargin: CGFloat = 12
            public static let debugOverlayPadding: CGFloat = 10
        }
    }

    // MARK: ContinueButton (footer primary action button styling)

    public enum ContinueButton {
        public enum Figma {
            public static let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            public static let cornerRadius: CGFloat = 14
        }

        public enum Experimental {
            public static let titleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
            public static let cornerRadius: CGFloat = 16
        }
    }

    // MARK: Icon (absolute icon sizes per variant)

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

    // MARK: Motion (absolute animation values per variant)

    public enum Motion {
        public enum Figma {
            public static let duration: TimeInterval = 0.4
            public static let springDamping: CGFloat = 0.8
            public static let reducedMotionScale: CGFloat = 0.5
        }

        public enum Experimental {
            public static let duration: TimeInterval = 0.35
            public static let springDamping: CGFloat = 0.85
            public static let reducedMotionScale: CGFloat = 0.5
        }
    }
}
