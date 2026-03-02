import UIKit

extension UIView {
    public func applyContinueButtonStyle(theme: Theme) {
        layer.cornerRadius = theme.continueButton.cornerRadius
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
}
