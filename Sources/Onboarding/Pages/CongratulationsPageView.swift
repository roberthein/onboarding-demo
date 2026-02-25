import UIKit

public final class CongratulationsPageView: ScrollablePageView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 4
        return label
    }()

    private lazy var stack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = Theme.figma.spacing.item
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContent()
    }

    private func setupContent() {
        centeredContentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])
    }

    public func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    public func setSubtitle(_ text: String) {
        subtitleLabel.text = text
    }
}

extension CongratulationsPageView: PageContentView {
    public func apply(theme: Theme) {
        titleLabel.applyTitleStyle(theme: theme)
        subtitleLabel.applySubtitleStyle(theme: theme)
    }
}

extension CongratulationsPageView {
    public func updateAppearance(progress: CGFloat) {
        titleLabel.alpha = progress
        subtitleLabel.alpha = progress
    }
}
