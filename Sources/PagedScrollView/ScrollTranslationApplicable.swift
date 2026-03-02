import UIKit

@MainActor
public protocol ScrollTranslationApplicable: AnyObject {
    func applyScrollTranslation(contentOffsetX: CGFloat, pageWidth: CGFloat)
}
