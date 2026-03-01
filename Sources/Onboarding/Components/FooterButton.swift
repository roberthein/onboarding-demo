import UIKit

public final class FooterButton: UIControl {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    public var title: String? {
        get { label.text }
        set {
            label.text = newValue
            updateAppearance()
        }
    }

    override public var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    private var theme: Theme?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
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
        applyContinueButtonStyle(theme: theme)
        updateAppearance()
    }

    private func updateAppearance() {
        guard let theme else { return }
        let font = theme.continueButton.titleFont
        let kern = theme.continueButton.titleKern
        let color = theme.color.onAccent
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.textStyle.continueButtonLineHeightMultiple
        paragraphStyle.alignment = .center
        label.attributedText = NSAttributedString(
            string: label.text ?? "",
            attributes: [
                .font: font,
                .foregroundColor: color,
                .kern: kern,
                .paragraphStyle: paragraphStyle
            ]
        )

        backgroundColor = theme.color.accent
        alpha = isEnabled ? 1 : theme.continueButton.disabledAlpha
    }
}
