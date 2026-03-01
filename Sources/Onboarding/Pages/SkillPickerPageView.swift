import UIKit

public final class SkillPickerPageView: ScrollablePageView {
    private lazy var faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: SkillLevel.intermediate.faceImageName)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.SkillPicker.title
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.SkillPicker.subtitle
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var pickerView: SkillLevelPickerView = {
        let skillLevelPickerView = SkillLevelPickerView()
        skillLevelPickerView.translatesAutoresizingMaskIntoConstraints = false
        return skillLevelPickerView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var stackViewLeadingConstraint: NSLayoutConstraint?
    private var stackViewTrailingConstraint: NSLayoutConstraint?
    private var theme: Theme?

    var onPickerSelect: ((SkillLevel?) -> Void)? {
        get { pickerView.onSelect }
        set { pickerView.onSelect = newValue }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        stackView.addArrangedSubview(faceImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(pickerView)

        centeredContentView.addSubview(stackView)

        let leading = stackView.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor)
        let trailing = stackView.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor)
        stackViewLeadingConstraint = leading
        stackViewTrailingConstraint = trailing
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            leading,
            trailing,
            stackView.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])
    }

    public func setSelected(_ level: SkillLevel?, animate: Bool = false) {
        pickerView.setSelected(level)
        updateFaceImage(for: level, animate: animate)
    }

    private func updateFaceImage(for level: SkillLevel?, animate: Bool = false) {
        let imageName = level?.faceImageName ?? SkillLevel.intermediate.faceImageName
        faceImageView.image = UIImage(named: imageName)

        if animate {
            bounceRotateFaceImage()
        }
    }

    private func bounceRotateFaceImage() {
        let t = theme ?? Theme.fallback
        let face = t.skillPickerFace
        faceImageView.transform = CGAffineTransform(rotationAngle: -face.rotationAngle).scaledBy(x: 1.1, y: 1.1)
        UIView.animate(
            withDuration: face.bounceDuration,
            delay: 0,
            usingSpringWithDamping: face.bounceDamping,
            initialSpringVelocity: face.bounceVelocity
        ) {
            self.faceImageView.transform = .identity
        }
    }
}

extension SkillPickerPageView: PageContentView {
    public func apply(theme: Theme) {
        self.theme = theme
        stackView.spacing = theme.spacing.item
        let horizontalMargin = theme.skillPickerPage.horizontalMargin
        stackViewLeadingConstraint?.constant = horizontalMargin
        stackViewTrailingConstraint?.constant = -horizontalMargin
        titleLabel.applyLargeTitleStyle(theme: theme)
        subtitleLabel.applyTitle2StyleSubdued(theme: theme)
        pickerView.apply(theme: theme)

        stackView.setCustomSpacing(theme.spacing.content, after: faceImageView)
        stackView.setCustomSpacing(0, after: titleLabel)
        stackView.setCustomSpacing(theme.spacing.content, after: subtitleLabel)
    }
}

extension SkillPickerPageView {
    public func updateAppearance(progress: CGFloat) {
        titleLabel.alpha = progress
        subtitleLabel.alpha = progress
        pickerView.alpha = progress
    }
}
