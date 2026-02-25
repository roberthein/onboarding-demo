import UIKit

/// A custom UIControl for the footer primary action button.
/// Styled via Theme and AppStyle; state and content are driven by the container.
public final class FooterButton: UIControl {
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()

    public var title: String? {
        get { label.text }
        set { label.text = newValue }
    }

    override public var isEnabled: Bool {
        didSet { updateAppearance() }
    }

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
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        updateAppearance()
    }

    public func apply(theme: Theme) {
        self.theme = theme
        label.font = theme.continueButton.titleFont
        applyContinueButtonStyle(theme: theme)
        updateAppearance()
    }

    private func updateAppearance() {
        if isEnabled {
            backgroundColor = theme.color.accent
            label.textColor = theme.color.onAccent
        } else {
            backgroundColor = theme.color.surface
            label.textColor = theme.color.textSecondary
        }
    }
}
