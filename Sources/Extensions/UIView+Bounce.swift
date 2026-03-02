import UIKit

public extension UIView {

    func bounce(
        scale: CGFloat = 0.92,
        duration: TimeInterval = 0.45,
        damping: CGFloat = 0.5,
        velocity: CGFloat = 0.6,
        completion: (() -> Void)? = nil
    ) {
        let startTransform = transform
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        transform = startTransform.concatenating(scaleTransform)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity
        ) {
            self.transform = startTransform
        } completion: { _ in
            completion?()
        }
    }
}
