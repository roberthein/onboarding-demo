import SwiftUI
import UIKit

struct OnboardingGradientView: View {
    let progress: CGFloat
    let primaryColor: UIColor
    let secondaryColor: UIColor

    private var primary: Color { Color(uiColor: primaryColor) }
    private var secondary: Color { Color(uiColor: secondaryColor) }

    var body: some View {
        gradient
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }

    private var gradient: LinearGradient {
        let (startPoint, endPoint, startColor, endColor) = interpolatedValues
        return LinearGradient(
            colors: [startColor, endColor],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    private var interpolatedValues: (UnitPoint, UnitPoint, Color, Color) {
        if progress < 0 {
            let t = (progress + 1).easeInOut()
            let start = UnitPoint(x: 0.5 + 0.5 * t, y: 0.5 * (1 - t))
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(secondaryColor, primaryColor, blend: t))
            return (start, end, secondary, endColor)
        } else if progress <= 2 {
            return (
                UnitPoint(x: 1, y: 0),
                UnitPoint(x: 0.5, y: 1),
                secondary,
                primary
            )
        } else {
            let t = min(1, progress - 2).easeInOut()
            let start = UnitPoint(x: 1 - 0.5 * t, y: 0.5 * t)
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(primaryColor, secondaryColor, blend: t))
            return (start, end, secondary, endColor)
        }
    }

    private func blendColor(_ a: UIColor, _ b: UIColor, blend: CGFloat) -> UIColor {
        let t = min(max(blend, 0), 1)
        var ra: CGFloat = 0, ga: CGFloat = 0, ba: CGFloat = 0, aa: CGFloat = 0
        var rb: CGFloat = 0, gb: CGFloat = 0, bb: CGFloat = 0, ab: CGFloat = 0
        a.getRed(&ra, green: &ga, blue: &ba, alpha: &aa)
        b.getRed(&rb, green: &gb, blue: &bb, alpha: &ab)
        return UIColor(
            red: (1 - t) * ra + t * rb,
            green: (1 - t) * ga + t * gb,
            blue: (1 - t) * ba + t * bb,
            alpha: (1 - t) * aa + t * ab
        )
    }
}
