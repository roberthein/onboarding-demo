import UIKit

public final class SkillPickerPageViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private let viewModel: OnboardingViewModel
    private var themeTask: Task<Void, Never>?

    public var onSelectSkill: ((SkillLevel?) -> Void)?

    private var contentView: SkillPickerPageView {
        view as! SkillPickerPageView
    }

    public init(themeProvider: ThemeProviding, viewModel: OnboardingViewModel) {
        self.themeProvider = themeProvider
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        themeTask = Task { @MainActor [weak weakSelf = self] in
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                guard let weakSelf else { return }
                weakSelf.apply(theme: theme)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let contentView = SkillPickerPageView()
        contentView.onPickerSelect = { [weak self] level in
            self?.contentView.setSelected(level, animate: true)
            self?.viewModel.selectSkillLevel(level)
            self?.onSelectSkill?(level)
        }
        view = contentView
    }

    deinit {
        themeTask?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        Task { @MainActor [weak weakSelf = self] in
            guard let weakSelf else { return }
            let currentTheme = await themeProvider.currentTheme
            weakSelf.contentView.apply(theme: currentTheme)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.setSelected(viewModel.skillLevel)
    }
}

extension SkillPickerPageViewController: ThemedView {
    public func apply(theme: Theme) {
        contentView.apply(theme: theme)
    }
}

extension SkillPickerPageViewController: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        contentView.updateAppearance(progress: progress)
    }
}
