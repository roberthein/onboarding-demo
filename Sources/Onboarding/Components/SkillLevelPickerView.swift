import UIKit

public final class SkillLevelPickerView: UIView {
    private var buttons: [SkillLevel: UIButton] = [:]
    private var buttonHeightConstraints: [SkillLevel: NSLayoutConstraint] = [:]
    public var onSelect: ((SkillLevel?) -> Void)?
    private var theme: Theme?
    private var selectedLevel: SkillLevel?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
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
        SkillLevel.allCases.forEach { level in
            let button = UIButton(type: .custom)
            button.setTitle(level.displayName, for: .normal)
            button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            buttons[level] = button
            stackView.addArrangedSubview(button)
        }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func didTap(_ sender: UIButton) {
        guard let (level, _) = buttons.first(where: { $0.value === sender }) else { return }
        let newSelection: SkillLevel? = level == selectedLevel ? nil : level
        HapticsManager.selection()
        sender.bounce()
        setSelected(newSelection)
        onSelect?(newSelection)
    }

    public func setSelected(_ level: SkillLevel?) {
        UIView.performWithoutAnimation {
            selectedLevel = level
            buttons.forEach { (skillLevel, button) in
                button.isSelected = skillLevel == level
            }
            updateSelectionAppearance()
        }
    }
}

extension SkillLevelPickerView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        let picker = theme.skillLevelPicker
        stackView.spacing = picker.spacing
        for (level, button) in buttons {
            let constraint = buttonHeightConstraints[level]
                ?? button.heightAnchor.constraint(equalToConstant: picker.itemHeight)
            if buttonHeightConstraints[level] == nil {
                constraint.isActive = true
                buttonHeightConstraints[level] = constraint
            }
            constraint.constant = picker.itemHeight
        }
        updateAllButtonConfigurations()
    }
}

private extension SkillLevelPickerView {
    func updateSelectionAppearance() {
        updateAllButtonConfigurations()
    }

    func updateAllButtonConfigurations() {
        guard let theme else { return }
        let picker = theme.skillLevelPicker
        let textColor = theme.color.textPrimary

        buttons.forEach { (skillLevel, button) in
            let isSelected = skillLevel == selectedLevel
            var config = UIButton.Configuration.plain()
            let attributedTitle = NSAttributedString(
                string: skillLevel.displayName,
                attributes: [
                    .font: picker.font,
                    .foregroundColor: textColor,
                    .kern: picker.kern
                ]
            )
            config.attributedTitle = AttributedString(attributedTitle)
            config.baseForegroundColor = textColor
            config.image = checkboxImage(isSelected: isSelected)
            config.imagePlacement = .leading
            config.imagePadding = picker.imageTrailingMargin
            config.background.backgroundColor = theme.color.surface.withAlphaComponent(0.1)
            config.background.cornerRadius = theme.radius.medium
            config.background.strokeColor = isSelected ? theme.color.accent : .clear
            config.background.strokeWidth = isSelected ? picker.selectedStrokeWidth : 0
            config.contentInsets = .init(top: picker.paddingVertical, leading: picker.imageLeadingMargin, bottom: picker.paddingVertical, trailing: picker.paddingHorizontal)
            config.titleAlignment = .leading

            button.configuration = config
            button.configurationUpdateHandler = { _ in }
            button.contentHorizontalAlignment = .leading
            button.tintColor = textColor
        }
    }

    private func checkboxImage(isSelected: Bool) -> UIImage? {
        guard let theme else { return nil }

        return if theme.isExperimental {
            isSelected ? UIImage(named: "checkbox-filled-experimental") : UIImage(named: "checkbox")
        } else {
            isSelected ? UIImage(named: "checkbox-filled") : UIImage(named: "checkbox")
        }
    }
}
