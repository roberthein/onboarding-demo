import UIKit

public final class WelcomePageView: ScrollablePageView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover what you can build"
        label.textAlignment = .center
        label.numberOfLines = 2
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
}

extension WelcomePageView: PageContentView {
    public func apply(theme: Theme) {
        titleLabel.applyTitleStyle(theme: theme)
        subtitleLabel.applySubtitleStyle(theme: theme)
    }
}

extension WelcomePageView {
    public func updateAppearance(progress: CGFloat) {
        let scale = progress.map(from: 0...1, to: 0.92...1)
        let alpha = progress
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        titleLabel.alpha = alpha
        subtitleLabel.alpha = max(0, progress.map(from: 0.3...1, to: 0...1))
    }
}
