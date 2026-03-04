import UIKit

public final class CongratulationsPageView: ScrollablePageView {
    private var skillLevel: SkillLevel?
    private var stackLeadingConstraint: NSLayoutConstraint?
    private var stackTrailingConstraint: NSLayoutConstraint?

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
        let leading = stack.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor, constant: 0)
        let trailing = stack.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor, constant: 0)
        stackLeadingConstraint = leading
        stackTrailingConstraint = trailing
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            leading,
            trailing,
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
        stackLeadingConstraint?.constant = theme.margin.outer
        stackTrailingConstraint?.constant = -theme.margin.outer
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
