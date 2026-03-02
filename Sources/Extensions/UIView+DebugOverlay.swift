import UIKit
import ObjectiveC

private final class DebugOverlayHost {
    let tintOverlay: UIView
    var infoContainer: UIView?
    var infoLabel: UILabel?
    var labelTopConstraint: NSLayoutConstraint?
    var labelLeadingConstraint: NSLayoutConstraint?
    var labelTrailingConstraint: NSLayoutConstraint?
    var labelBottomConstraint: NSLayoutConstraint?
    var containerTopConstraint: NSLayoutConstraint?
    var containerLeadingConstraint: NSLayoutConstraint?

    init(tintOverlay: UIView) {
        self.tintOverlay = tintOverlay
    }
}

private var debugOverlayHostKey: UInt8 = 0

extension UIView {

    public func installDebugOverlay(tintColor: UIColor = UIColor.systemRed.withAlphaComponent(0.06)) {
        guard debugOverlayHost == nil else { return }

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = tintColor
        addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        bringSubviewToFront(overlay)

        debugOverlayHost = DebugOverlayHost(tintOverlay: overlay)
    }

    public func installDebugOverlayWithInfo(tintColor: UIColor = UIColor.systemRed.withAlphaComponent(0.06)) {
        guard debugOverlayHost == nil else { return }

        installDebugOverlay(tintColor: tintColor)
        guard let host = debugOverlayHost else { return }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerCurve = .continuous
        container.layer.masksToBounds = true
        container.isHidden = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "—"

        container.addSubview(label)
        addSubview(container)

        host.labelTopConstraint = label.topAnchor.constraint(equalTo: container.topAnchor)
        host.labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: container.leadingAnchor)
        host.labelTrailingConstraint = label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        host.labelBottomConstraint = label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        host.containerTopConstraint = container.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        host.containerLeadingConstraint = container.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)

        NSLayoutConstraint.activate([
            host.labelTopConstraint!, host.labelLeadingConstraint!, host.labelTrailingConstraint!, host.labelBottomConstraint!,
            host.containerTopConstraint!, host.containerLeadingConstraint!,
        ])
        bringSubviewToFront(container)

        host.infoContainer = container
        host.infoLabel = label
    }

    public func setDebugOverlayVisible(_ visible: Bool) {
        debugOverlayHost?.tintOverlay.isHidden = !visible
        debugOverlayHost?.infoContainer?.isHidden = !visible
    }

    public func updateDebugOverlayInfo(_ text: String, theme: Theme) {
        guard let host = debugOverlayHost, let label = host.infoLabel, let container = host.infoContainer else { return }
        label.applyDebugStyle(theme: theme)
        label.text = text
        container.backgroundColor = theme.color.debugOverlayBackground
        container.layer.cornerRadius = theme.radius.small
        let padding = theme.layout.debugOverlayPadding
        let margin = theme.layout.debugOverlayMargin
        host.labelTopConstraint?.constant = padding
        host.labelLeadingConstraint?.constant = padding
        host.labelTrailingConstraint?.constant = -padding
        host.labelBottomConstraint?.constant = -padding
        host.containerTopConstraint?.constant = margin
        host.containerLeadingConstraint?.constant = margin
    }

    private var debugOverlayHost: DebugOverlayHost? {
        get { objc_getAssociatedObject(self, &debugOverlayHostKey) as? DebugOverlayHost }
        set { objc_setAssociatedObject(self, &debugOverlayHostKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
