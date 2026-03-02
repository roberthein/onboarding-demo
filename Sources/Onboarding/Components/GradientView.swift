import SwiftUI
import UIKit

struct GradientView: View {
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
            let easedProgress = (progress + 1).easeInOut()
            let start = UnitPoint(x: 0.5 + 0.5 * easedProgress, y: 0.5 * (1 - easedProgress))
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(secondaryColor, primaryColor, blend: easedProgress))
            return (start, end, secondary, endColor)
        } else if progress <= 2 {
            return (
                UnitPoint(x: 1, y: 0),
                UnitPoint(x: 0.5, y: 1),
                secondary,
                primary
            )
        } else {
            let easedProgress = min(1, progress - 2).easeInOut()
            let start = UnitPoint(x: 1 - 0.5 * easedProgress, y: 0.5 * easedProgress)
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(primaryColor, secondaryColor, blend: easedProgress))
            return (start, end, secondary, endColor)
        }
    }

    private func blendColor(_ first: UIColor, _ second: UIColor, blend: CGFloat) -> UIColor {
        let blendFactor = min(max(blend, 0), 1)
        var redFirst: CGFloat = 0, greenFirst: CGFloat = 0, blueFirst: CGFloat = 0, alphaFirst: CGFloat = 0
        var redSecond: CGFloat = 0, greenSecond: CGFloat = 0, blueSecond: CGFloat = 0, alphaSecond: CGFloat = 0
        first.getRed(&redFirst, green: &greenFirst, blue: &blueFirst, alpha: &alphaFirst)
        second.getRed(&redSecond, green: &greenSecond, blue: &blueSecond, alpha: &alphaSecond)
        return UIColor(
            red: (1 - blendFactor) * redFirst + blendFactor * redSecond,
            green: (1 - blendFactor) * greenFirst + blendFactor * greenSecond,
            blue: (1 - blendFactor) * blueFirst + blendFactor * blueSecond,
            alpha: (1 - blendFactor) * alphaFirst + blendFactor * alphaSecond
        )
    }
}
