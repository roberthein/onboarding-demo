import UIKit

public final class SkillPickerPageViewController: UIViewController {
    let themeProvider: ThemeProviding
    private let viewModel: OnboardingViewModel
    private var themeTask: Task<Void, Never>?

    private var contentView: SkillPickerPageView {
        view as! SkillPickerPageView
    }

    public init(themeProvider: ThemeProviding, viewModel: OnboardingViewModel) {
        self.themeProvider = themeProvider
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        themeTask = startThemeSubscription()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let contentView = SkillPickerPageView()
        contentView.onPickerSelect = { [weak self] level in
            self?.contentView.setSelected(level, animate: true)
            self?.viewModel.selectSkillLevel(level)
        }
        view = contentView
    }

    deinit {
        themeTask?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        applyInitialTheme()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.setSelected(viewModel.skillLevel)
    }
}

extension SkillPickerPageViewController: ThemeSubscribing {}

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
