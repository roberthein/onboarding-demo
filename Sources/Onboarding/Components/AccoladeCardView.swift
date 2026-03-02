import UIKit

public final class AccoladeCardView: UIView {
    private var theme: Theme?
    private var accolade: Accolade?
    private var iconWidthConstraint: NSLayoutConstraint?
    private var iconHeightConstraint: NSLayoutConstraint?

    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "accolades-left")
        return imageView
    }()

    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "accolades-right")
        return imageView
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = nil
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private lazy var centerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var titleRowStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        translatesAutoresizingMaskIntoConstraints = false
        titleRowStack.addArrangedSubview(iconImageView)
        titleRowStack.addArrangedSubview(titleLabel)
        centerStack.addArrangedSubview(titleRowStack)
        centerStack.addArrangedSubview(subtitleLabel)
        mainStack.addArrangedSubview(leftImageView)
        mainStack.addArrangedSubview(centerStack)
        mainStack.addArrangedSubview(rightImageView)
        addSubview(mainStack)
        let iconSize = Theme.fallback.accoladeCard.iconSize
        iconWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: iconSize)
        iconHeightConstraint = iconImageView.heightAnchor.constraint(equalToConstant: iconSize)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconWidthConstraint!,
            iconHeightConstraint!,
        ])
    }

    public func configure(accolade: Accolade) {
        self.accolade = accolade
        titleLabel.text = accolade.title
        subtitleLabel.text = accolade.subtitle
        let resolvedTheme = theme ?? Theme.fallback
        let iconSize = resolvedTheme.accoladeCard.iconSize
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
        iconImageView.image = UIImage(systemName: accolade.icon.sfSymbolName, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = nil
        if let currentTheme = theme {
            apply(theme: currentTheme)
        }
    }
}

extension AccoladeCardView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        let iconSize = theme.accoladeCard.iconSize
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
        if let currentAccolade = accolade,
           let symbolImage = UIImage(systemName: currentAccolade.icon.sfSymbolName, withConfiguration: config) {
            iconImageView.image = symbolImage.withRenderingMode(.alwaysTemplate)
        }
        iconImageView.tintColor = theme.color.textPrimary
        centerStack.spacing = theme.accoladeCard.centerStackSpacing
        titleRowStack.spacing = theme.accoladeCard.titleRowSpacing
        mainStack.spacing = theme.accoladeCard.mainStackSpacing
        iconWidthConstraint?.constant = iconSize
        iconHeightConstraint?.constant = iconSize
        titleLabel.applyAccoladeTitleStyle(theme: theme)
        subtitleLabel.applyAccoladeSubtitleStyle(theme: theme)
    }
}
