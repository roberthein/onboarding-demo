import UIKit

public final class AccoladeCardView: UIView {
    private var theme: Theme?

    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private lazy var stack: UIStackView = {
        let defaultTheme = Theme.figma
        let stackView = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = defaultTheme.margin.inner
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        return stackView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        _ = stack
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _ = stack
    }

    public func configure(accolade: Accolade) {
        iconLabel.text = accolade.icon.emoji
        titleLabel.text = accolade.title
        subtitleLabel.text = accolade.subtitle
        if let currentTheme = self.theme {
            apply(theme: currentTheme)
        }
    }
}

extension AccoladeCardView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        iconLabel.applyIconStyle(theme: theme)
        titleLabel.applyHeadlineStyle(theme: theme)
        subtitleLabel.applySubtitleStyle(theme: theme)
    }
}
