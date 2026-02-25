import UIKit

public final class SkillPickerPageView: ScrollablePageView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's your experience level?"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var pickerView: SkillLevelPickerView = {
        let skillLevelPicker = SkillLevelPickerView()
        skillLevelPicker.translatesAutoresizingMaskIntoConstraints = false
        return skillLevelPicker
    }()

    var onPickerSelect: ((SkillLevel?) -> Void)? {
        get { pickerView.onSelect }
        set { pickerView.onSelect = newValue }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContent()
    }

    private func setupContent() {
        let defaultTheme = Theme.figma
        centeredContentView.addSubview(titleLabel)
        centeredContentView.addSubview(pickerView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor, constant: defaultTheme.margin.outer),
            titleLabel.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor, constant: -defaultTheme.margin.outer),
            pickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: defaultTheme.spacing.content),
            pickerView.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor, constant: defaultTheme.margin.outer),
            pickerView.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor, constant: -defaultTheme.margin.outer),
            pickerView.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])
    }

    public func setSelected(_ level: SkillLevel?) {
        pickerView.setSelected(level)
    }
}

extension SkillPickerPageView: PageContentView {
    public func apply(theme: Theme) {
        titleLabel.applyHeadlineStyle(theme: theme)
        pickerView.apply(theme: theme)
    }
}

extension SkillPickerPageView {
    public func updateAppearance(progress: CGFloat) {
        titleLabel.alpha = progress
        pickerView.alpha = progress
    }
}
