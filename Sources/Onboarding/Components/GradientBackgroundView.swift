import SwiftUI
import UIKit

public final class GradientBackgroundView: UIView {

    private var hostingController: UIHostingController<GradientView>?
    private var primaryColor: UIColor = .black
    private var secondaryColor: UIColor = .darkGray
    private var lastProgress: CGFloat = -1

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, hostingController == nil {
            installHostingController()
        }
    }

    private func installHostingController() {
        guard let parentVC = nearestViewController else { return }
        let view = GradientView(
            progress: lastProgress,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor
        )
        let hosting = UIHostingController(rootView: view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        parentVC.addChild(hosting)
        addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        hosting.didMove(toParent: parentVC)
        hostingController = hosting
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController { return viewController }
            responder = next
        }
        return nil
    }

    public func setColors(primary: UIColor, secondary: UIColor) {
        primaryColor = primary
        secondaryColor = secondary
        backgroundColor = primary
        updateHostedView()
    }

    public func setProgress(_ progress: CGFloat) {
        lastProgress = progress
        updateHostedView()
    }

    private func updateHostedView() {
        guard let hosting = hostingController else { return }
        hosting.rootView = GradientView(
            progress: lastProgress,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor
        )
    }
}
