import UIKit

public final class SkillLevelPickerView: UIView {
    private var buttons: [SkillLevel: UIButton] = [:]
    public var onSelect: ((SkillLevel?) -> Void)?
    private var theme: Theme?
    private var selectedLevel: SkillLevel?

    private lazy var stack: UIStackView = {
        let defaultTheme = Theme.figma
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = defaultTheme.spacing.item
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        SkillLevel.allCases.forEach { level in
            let button = UIButton(type: .system)
            button.setTitle(level.displayName, for: .normal)
            button.accessibilityLabel = level.displayName
            button.accessibilityHint = "Selects \(level.displayName) as your experience level"
            button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: defaultTheme.layout.buttonHeight).isActive = true
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

    @objc private func didTap(_ sender: UIButton) {
        guard let (level, _) = buttons.first(where: { $0.value === sender }) else { return }
        let newSelection: SkillLevel? = level == selectedLevel ? nil : level
        setSelected(newSelection)
        onSelect?(newSelection)
    }

    public func setSelected(_ level: SkillLevel?) {
        selectedLevel = level
        buttons.forEach { (skillLevel, button) in
            button.isSelected = skillLevel == level
        }
        updateSelectionAppearance()
    }
}

extension SkillLevelPickerView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        buttons.forEach { (skillLevel, button) in
            var config = UIButton.Configuration.plain()
            config.title = skillLevel.displayName
            config.baseForegroundColor = theme.color.textPrimary
            config.background.backgroundColor = theme.color.surface
            config.background.cornerRadius = theme.radius.medium
            config.contentInsets = .init(top: theme.spacing.md, leading: theme.spacing.lg, bottom: theme.spacing.md, trailing: theme.spacing.lg)
            button.configuration = config
        }
        updateSelectionAppearance()
    }
}

private extension SkillLevelPickerView {
    func updateSelectionAppearance() {
        guard let currentTheme = theme else { return }
        buttons.forEach { (_, button) in
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.baseForegroundColor = button.isSelected ? currentTheme.color.accent : currentTheme.color.textPrimary
            config.background.strokeColor = button.isSelected ? currentTheme.color.accent : .clear
            config.background.strokeWidth = button.isSelected ? 2 : 0
            button.configuration = config
        }
    }
}
