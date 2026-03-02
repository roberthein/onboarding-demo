import UIKit

public final class CongratulationsPageView: ScrollablePageView {
    private var skillLevel: SkillLevel?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 4
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

    public func configure(title: String, subtitle: String, skillLevel: SkillLevel? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        self.skillLevel = skillLevel
    }

    public func setSubtitle(_ text: String) {
        subtitleLabel.text = text
    }
}

extension CongratulationsPageView: PageContentView {
    public func apply(theme: Theme) {
        stack.spacing = theme.spacing.item
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
