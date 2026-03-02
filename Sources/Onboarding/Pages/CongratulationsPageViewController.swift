import UIKit

public final class CongratulationsPageViewController: UIViewController {
    let themeProvider: ThemeProviding
    private let onboardingViewModel: OnboardingViewModel
    private var themeTask: Task<Void, Never>?

    private var contentView: CongratulationsPageView {
        view as! CongratulationsPageView
    }

    public init(themeProvider: ThemeProviding, onboardingViewModel: OnboardingViewModel) {
        self.themeProvider = themeProvider
        self.onboardingViewModel = onboardingViewModel
        super.init(nibName: nil, bundle: nil)
        themeTask = startThemeSubscription()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let contentView = CongratulationsPageView()
        contentView.configure(title: CongratulationsContent.title, subtitle: CongratulationsContent.subtitle(for: onboardingViewModel.skillLevel))
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
        refreshContent()
    }

    public func refreshContent() {
        contentView.configure(title: CongratulationsContent.title, subtitle: CongratulationsContent.subtitle(for: onboardingViewModel.skillLevel))
    }
}

extension CongratulationsPageViewController: ThemeSubscribing {}

extension CongratulationsPageViewController: ThemedView {
    public func apply(theme: Theme) {
        contentView.apply(theme: theme)
    }
}

extension CongratulationsPageViewController: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        contentView.updateAppearance(progress: progress)
    }
}
