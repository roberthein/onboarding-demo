import UIKit

public final class OnboardingContainerViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private let debugProvider: DebugProviding
    private let progressCoordinator: ScrollProgressCoordinator
    private let viewModel: OnboardingViewModel
    private var pageViewControllers: [UIViewController] = []
    private var progressTask: Task<Void, Never>?
    private var themeTask: Task<Void, Never>?
    private var debugTask: Task<Void, Never>?
    private var lastThemeId: String?
    private var lastTheme: Theme?
    private var lastScrollSnapshot: ScrollProgressSnapshot?

    private var containerView: OnboardingContainerView {
        view as! OnboardingContainerView
    }

    public init(
        themeProvider: ThemeProviding,
        debugProvider: DebugProviding,
        progressCoordinator: ScrollProgressCoordinator
    ) {
        self.themeProvider = themeProvider
        self.debugProvider = debugProvider
        self.progressCoordinator = progressCoordinator
        self.viewModel = OnboardingViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = OnboardingContainerView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor [weak weakSelf = self] in
            guard let weakSelf else { return }
            let theme = await themeProvider.currentTheme
            weakSelf.view.backgroundColor = theme.color.primaryBackground
        }

        let congratsViewModel = CongratulationsViewModel(onboardingViewModel: viewModel)
        let welcome = WelcomePageViewController(themeProvider: themeProvider)
        let accolades = AccoladesPageViewController(themeProvider: themeProvider)
        let skillPicker = SkillPickerPageViewController(themeProvider: themeProvider, viewModel: viewModel)
        let congrats = CongratulationsPageViewController(themeProvider: themeProvider, viewModel: congratsViewModel)

        pageViewControllers = [welcome, accolades, skillPicker, congrats]
        addChildViewControllers()
        let pageHosts = pageViewControllers.map { vc in vc.view! }
        containerView.pagingView.configure(numberOfPages: 4, pageViews: pageHosts)

        containerView.pagingView.onProgress { [progressCoordinator] snapshot in
            Task { await progressCoordinator.report(snapshot) }
        }

        setupFooter()

        progressTask = Task { @MainActor [weak weakSelf = self] in
            let stream = await progressCoordinator.progressStream()
            for await snapshot in stream {
                guard let weakSelf else { return }
                weakSelf.lastScrollSnapshot = snapshot
                weakSelf.handleProgress(snapshot)
                weakSelf.refreshDebugOverlay()
            }
        }

        setupThemeStream()
        setupDebugStream()
        Task { @MainActor in
            let theme = await themeProvider.currentTheme
            lastThemeId = theme.id
            lastTheme = theme
            await refreshAll()
        }
    }

    deinit {
        progressTask?.cancel()
        themeTask?.cancel()
        debugTask?.cancel()
    }

    override public func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        let savedPageIndex = containerView.pagingView.currentPageIndex
        coordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
            self.containerView.pagingView.scrollToPage(savedPageIndex, animated: false)
        }, completion: { _ in
            self.refreshFooterState(activePageIndex: savedPageIndex)
        })
    }

    // MARK: Streams

    private func setupThemeStream() {
        themeTask = Task { @MainActor [weak weakSelf = self] in
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                guard let weakSelf else { return }
                let isThemeChange = weakSelf.lastTheme != nil && weakSelf.lastTheme != theme
                weakSelf.lastThemeId = theme.id
                weakSelf.lastTheme = theme
                let isDebugEnabled = await weakSelf.debugProvider.isDebugEnabled
                weakSelf.applyThemeAnimated(theme: theme, isDebugEnabled: isDebugEnabled, animate: isThemeChange)
            }
        }
    }

    private func setupDebugStream() {
        debugTask = Task { @MainActor [weak weakSelf = self] in
            let stream = await debugProvider.debugStream()
            for await isDebugEnabled in stream {
                guard let weakSelf else { return }
                await weakSelf.refreshAll()
            }
        }
    }

    private func refreshAll() async {
        let theme = await themeProvider.currentTheme
        let isDebugEnabled = await debugProvider.isDebugEnabled
        lastTheme = theme
        applyThemeUpdates(theme: theme, isDebugEnabled: isDebugEnabled)
    }

    private func applyThemeAnimated(theme: Theme, isDebugEnabled: Bool, animate: Bool) {
        let duration = animate ? adjustedAnimationDuration(for: theme) : 0
        let updates = {
            self.applyThemeUpdates(theme: theme, isDebugEnabled: isDebugEnabled)
        }
        if duration > 0 {
            UIView.transition(with: view, duration: duration, options: [.transitionCrossDissolve]) {
                updates()
            }
        } else {
            updates()
        }
    }

    private func adjustedAnimationDuration(for theme: Theme) -> TimeInterval {
        let base = theme.motion.duration
        return UIAccessibility.isReduceMotionEnabled ? base * theme.motion.reducedMotionScale : base
    }

    private func applyThemeUpdates(theme: Theme, isDebugEnabled: Bool) {
        let menu = buildSettingsMenu(theme: theme, isDebugEnabled: isDebugEnabled)
        containerView.setSettingsMenu(menu, image: AppIcon.gearshape.image(theme: theme), tintColor: theme.color.textPrimary)
        applyDebugMode(isDebugEnabled: isDebugEnabled, theme: theme)
        view.backgroundColor = theme.color.primaryBackground
        containerView.footerView.apply(theme: theme)
        pageViewControllers.forEach { ($0 as? ThemedView)?.apply(theme: theme) }
        refreshFooterState()
        refreshDebugOverlay()
    }

    private func buildSettingsMenu(theme: Theme, isDebugEnabled: Bool) -> UIMenu {
        let figmaAction = UIAction(
            title: "Figma",
            image: AppIcon.sunMax.image(theme: theme),
            state: theme == .figma ? .on : .off
        ) { [weak self] _ in
            Task { await self?.themeProvider.setTheme(.figma) }
        }
        let experimentalAction = UIAction(
            title: "Experimental",
            image: AppIcon.moon.image(theme: theme),
            state: theme == .experimental ? .on : .off
        ) { [weak self] _ in
            Task { await self?.themeProvider.setTheme(.experimental) }
        }
        let debugAction = UIAction(
            title: "Debug",
            image: AppIcon.ant.image(theme: theme),
            state: isDebugEnabled ? .on : .off
        ) { [weak self] _ in
            Task { await self?.toggleDebugMode() }
        }

        let themeMenu = UIMenu(title: "Appearance", options: .displayInline, children: [figmaAction, experimentalAction])
        let debugMenu = UIMenu(title: "Developer", options: .displayInline, children: [debugAction])
        return UIMenu(children: [themeMenu, debugMenu])
    }

    private func toggleDebugMode() async {
        let current = await debugProvider.isDebugEnabled
        await debugProvider.setDebugEnabled(!current)
    }

    private func applyDebugMode(isDebugEnabled: Bool, theme: Theme) {
        containerView.setDebugModeEnabled(isDebugEnabled, themeBackground: theme.color.primaryBackground)
        containerView.pagingView.setDebugModeEnabled(isDebugEnabled)
        pageViewControllers.forEach { vc in
            (vc.view as? ScrollablePageView)?.setDebugModeEnabled(isDebugEnabled)
        }
    }

    // MARK: Debug Overlay

    private func refreshDebugOverlay() {
        let theme = lastTheme ?? .figma
        containerView.setDebugInfo(themeId: lastThemeId, scrollSnapshot: lastScrollSnapshot, theme: theme)
    }

    private func addChildViewControllers() {
        pageViewControllers.forEach { viewController in
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
    }

    private func handleProgress(_ snapshot: ScrollProgressSnapshot) {
        snapshot.pageProgress.forEach { progressItem in
            guard let viewController = pageViewControllers[safe: progressItem.pageIndex] else { return }
            (viewController as? PageAppearanceUpdatable)?.updateAppearance(progress: progressItem.progress)
        }
        updateFooter(snapshot: snapshot)
    }

    // MARK: Footer

    private func setupFooter() {
        containerView.footerView.onContinueTapped = { [weak self] in
            self?.handleContinueTapped()
        }
        containerView.pagingView.shouldAllowScrollToPage = { [weak self] page in
            guard page == 3 else { return true }
            return self?.viewModel.skillLevel != nil
        }
        viewModel.onSkillLevelChanged = { [weak self] _ in
            Task { @MainActor in
                self?.refreshFooterState()
            }
        }
        refreshFooterState(activePageIndex: 0)
    }

    private func handleContinueTapped() {
        let nextIndex = min(containerView.pagingView.currentPageIndex + 1, 3)
        containerView.pagingView.scrollToPage(nextIndex, animated: true)
    }

    private func updateFooter(snapshot: ScrollProgressSnapshot) {
        let activePage = snapshot.pageProgress.first { $0.isActive }?.pageIndex ?? 0
        let progressToFourthScreen = snapshot.progress(forPage: 3)
        refreshFooterState(activePageIndex: activePage, progressToFourthScreen: progressToFourthScreen)
    }

    private func refreshFooterState(activePageIndex: Int? = nil, progressToFourthScreen: CGFloat? = nil) {
        let pageIndex = activePageIndex ?? containerView.pagingView.currentPageIndex
        let footer = containerView.footerView
        let theme = lastTheme ?? .figma

        let progress: CGFloat
        if let p = progressToFourthScreen {
            progress = p
        } else {
            progress = pageIndex >= 3 ? 1 : 0
        }

        let footerReservedHeight = (theme.layout.footerButtonHeight + theme.layout.footerBottomPadding) * (1 - progress)
        containerView.setFooterReservedHeight(footerReservedHeight)

        footer.setVisibilityProgress(progress)

        let title: String
        let isEnabled: Bool
        switch pageIndex {
        case 0, 1:
            title = "Continue"
            isEnabled = true
        case 2:
            title = "Let's go"
            isEnabled = viewModel.skillLevel != nil
        default:
            title = "Continue"
            isEnabled = true
        }

        footer.continueButton.title = title
        footer.continueButton.isEnabled = isEnabled
    }
}
