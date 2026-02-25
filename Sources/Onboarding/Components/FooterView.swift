import UIKit

/// Footer view containing the primary action button.
/// Visibility is driven by scroll progress when moving to the fourth screen (0 = visible, 1 = hidden).
/// State (title, enabled) is driven externally; actions are passed through callbacks.
public final class FooterView: UIView {
    public lazy var continueButton: FooterButton = {
        let button = FooterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public var onContinueTapped: (() -> Void)?

    private var theme: Theme = .figma

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(continueButton)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: topAnchor),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func continueButtonTapped() {
        onContinueTapped?()
    }

    public func apply(theme: Theme) {
        self.theme = theme
        continueButton.apply(theme: theme)
    }

    /// Updates visibility from scroll progress toward the fourth screen. 0 = fully visible, 1 = fully hidden (slid down off screen).
    public func setVisibilityProgress(_ progress: CGFloat) {
        let clamped = min(1, max(0, progress))
        let slideDistance = theme.layout.footerButtonHeight + theme.layout.footerBottomPadding + theme.layout.footerSlideOffset
        transform = CGAffineTransform(translationX: 0, y: slideDistance * clamped)
        isHidden = clamped >= 1
        isUserInteractionEnabled = clamped < 1
    }
}
