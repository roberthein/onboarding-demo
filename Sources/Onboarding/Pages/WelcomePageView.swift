import UIKit

public final class WelcomePageView: ScrollablePageView {
    private var theme: Theme?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.Welcome.title
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.Welcome.subtitle
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
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
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
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
        self.theme = theme
        stack.spacing = theme.spacing.item
        titleLabel.applyTitleStyle(theme: theme)
        subtitleLabel.applySubtitleStyle(theme: theme)
    }
}

extension WelcomePageView {
    public func updateAppearance(progress: CGFloat) {
        let t = theme ?? Theme.fallback
        let wp = t.welcomePage
        let scale = progress.map(from: 0...1, to: wp.titleScaleMin...wp.titleScaleMax)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        titleLabel.alpha = progress
        subtitleLabel.alpha = max(0, progress.map(from: wp.subtitleFadeStart...wp.subtitleFadeEnd, to: 0...1))
    }
}
