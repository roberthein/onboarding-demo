import UIKit

private let appearAnimationDurationMultiplier: TimeInterval = 3

public final class OnboardingContainerViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private let debugProvider: DebugProviding
    private let progressCoordinator: ScrollProgressCoordinator
    private let viewModel: OnboardingViewModel
    private var mainContentView: MainContentView!
    private var pageViewControllers: [UIViewController] = []
    private var pageAppearanceUpdatables: [PageAppearanceUpdatable] = []
    private var progressTask: Task<Void, Never>?
    private var themeTask: Task<Void, Never>?
    private var debugTask: Task<Void, Never>?
    private var skillLevelTask: Task<Void, Never>?
    private var lastTheme: Theme?
    private var lastScrollSnapshot: ScrollProgressSnapshot?
    private var hasAppearAnimationCompleted = false
    private var appearAnimator: DisplayLinkAnimator?
    private var appearAnimationTask: Task<Void, Never>?

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

        mainContentView = MainContentView(
            accolade: Accolade(icon: .appleLogo, title: LocalizedStrings.MainContent.appleDesignAward, subtitle: LocalizedStrings.MainContent.winner)
        )
        let accolades = AccoladesPageViewController(themeProvider: themeProvider)
        let skillPicker = SkillPickerPageViewController(themeProvider: themeProvider, viewModel: viewModel)
        let congrats = CongratulationsPageViewController(themeProvider: themeProvider, onboardingViewModel: viewModel)

        pageViewControllers = [accolades, skillPicker, congrats]
        pageAppearanceUpdatables = [mainContentView, accolades, skillPicker, congrats]
        addChildViewControllers()
        pageViewControllers.forEach { $0.loadViewIfNeeded() }
        let pageHosts: [UIView] = [mainContentView] + pageViewControllers.compactMap { $0.view }
        containerView.pagingView.configure(numberOfPages: viewModel.totalPages, pageViews: pageHosts)
        containerView.pagingView.onScroll = { [weak self] scrollView in
            guard let self else { return }
            let contentOffsetX = scrollView.contentOffset.x
            let pageWidth = scrollView.bounds.width > 0
                ? scrollView.bounds.width
                : self.containerView.pagingView.bounds.width
            guard pageWidth > 0 else { return }
            self.mainContentView.applyScrollTranslation(contentOffsetX: contentOffsetX, pageWidth: pageWidth)
        }

        progressCoordinator.connect(to: containerView.pagingView.progressStream())

        setupFooter()

        lastTheme = .figma
        applyThemeUpdates(theme: .figma, isDebugEnabled: false)

        progressTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await progressCoordinator.progressStream()
            for await snapshot in stream {
                lastScrollSnapshot = snapshot
                handleProgress(snapshot)
                refreshDebugOverlay()
            }
        }

        setupThemeStream()
        setupDebugStream()
        Task { @MainActor in
            await refreshAll()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAppearAnimation()
    }

    deinit {
        if let animator = appearAnimator {
            Task { @MainActor in
                animator.invalidate()
            }
        }
        appearAnimationTask?.cancel()
        progressTask?.cancel()
        themeTask?.cancel()
        debugTask?.cancel()
        skillLevelTask?.cancel()
    }

    private func runAppearAnimation() {
        guard !hasAppearAnimationCompleted else { return }
        appearAnimationTask = Task { @MainActor [weak self] in
            await self?.performAppearAnimation()
        }
    }

    private func performAppearAnimation() async {
        guard !hasAppearAnimationCompleted else { return }
        let theme = lastTheme ?? .figma
        let duration = theme.motion.duration * appearAnimationDurationMultiplier
        let startTime = CACurrentMediaTime()
        containerView.setGradientProgress(-1)
        mainContentView.setAppearProgress(0)
        containerView.footerView.setAppearProgress(0)
        containerView.pagingView.scrollView.isScrollEnabled = false

        let animator = DisplayLinkAnimator(startTime: startTime, duration: duration)
        appearAnimator = animator
        let stream = animator.progressStream()
        animator.start()

        for await normalizedProgress in stream {
            guard !Task.isCancelled else {
                animator.invalidate()
                return
            }
            let progress = -1 + normalizedProgress
            containerView.setGradientProgress(progress)
            mainContentView.setAppearProgress(normalizedProgress)
            mainContentView.updateAppearance(expansionProgress: 0)
            mainContentView.setVerticalOffsetProgress(progress)
            let appearAnimation = theme.appearAnimation
            let footerProgress = max(0, (normalizedProgress - appearAnimation.footerStartT) / (appearAnimation.footerEndT - appearAnimation.footerStartT))
            containerView.footerView.setAppearProgress(footerProgress)

            if normalizedProgress >= 1 {
                appearAnimator = nil
                hasAppearAnimationCompleted = true
                containerView.pagingView.scrollView.isScrollEnabled = true
                if let snapshot = lastScrollSnapshot {
                    containerView.setGradientProgress(snapshot.overallProgress)
                    mainContentView.setVerticalOffsetProgress(snapshot.overallProgress)
                    let expansionProgress = snapshot.overallProgress.clamped(to: 0...1)
                    mainContentView.updateAppearance(expansionProgress: expansionProgress)
                } else {
                    mainContentView.updateAppearance(expansionProgress: 0)
                }
                refreshFooterState()
            }
        }
    }

    override public func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        let savedPageIndex = containerView.pagingView.currentPageIndex
        Task { @MainActor in
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                coordinator.animate(alongsideTransition: { [weak self] _ in
                    self?.view.layoutIfNeeded()
                    self?.containerView.pagingView.scrollToPage(savedPageIndex, animated: false)
                }, completion: { [weak self] _ in
                    self?.refreshFooterState(activePageIndex: savedPageIndex)
                    continuation.resume()
                })
            }
        }
    }

    private func setupThemeStream() {
        themeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                let isThemeChange = lastTheme != nil && lastTheme != theme
                lastTheme = theme
                let isDebugEnabled = await debugProvider.isDebugEnabled
                applyThemeAnimated(theme: theme, isDebugEnabled: isDebugEnabled, animate: isThemeChange)
            }
        }
    }

    private func setupDebugStream() {
        debugTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await debugProvider.debugStream()
            for await _ in stream {
                await refreshAll()
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
        theme.motion.duration
    }

    private func applyThemeUpdates(theme: Theme, isDebugEnabled: Bool) {
        let menu = buildSettingsMenu(theme: theme, isDebugEnabled: isDebugEnabled)
        containerView.setSettingsMenu(menu, image: AppIcon.gearshape.image(theme: theme), tintColor: theme.color.textPrimary)
        applyDebugMode(isDebugEnabled: isDebugEnabled, theme: theme)
        containerView.apply(theme: theme)
        mainContentView.apply(theme: theme)
        pageViewControllers.forEach { ($0 as? ThemedView)?.apply(theme: theme) }
        refreshFooterState()
        refreshDebugOverlay()
    }

    private func buildSettingsMenu(theme: Theme, isDebugEnabled: Bool) -> UIMenu {
        let figmaAction = UIAction(
            title: LocalizedStrings.SettingsMenu.figma,
            image: AppIcon.sunMax.image(theme: theme),
            state: theme == .figma ? .on : .off
        ) { [weak self] _ in
            Task { await self?.themeProvider.setTheme(.figma) }
        }
        let experimentalAction = UIAction(
            title: LocalizedStrings.SettingsMenu.experimental,
            image: AppIcon.moon.image(theme: theme),
            state: theme == .experimental ? .on : .off
        ) { [weak self] _ in
            Task { await self?.themeProvider.setTheme(.experimental) }
        }
        let debugAction = UIAction(
            title: LocalizedStrings.SettingsMenu.debug,
            image: AppIcon.ant.image(theme: theme),
            state: isDebugEnabled ? .on : .off
        ) { [weak self] _ in
            Task { await self?.toggleDebugMode() }
        }

        let themeMenu = UIMenu(title: LocalizedStrings.SettingsMenu.appearance, options: .displayInline, children: [figmaAction, experimentalAction])
        let debugMenu = UIMenu(title: LocalizedStrings.SettingsMenu.developer, options: .displayInline, children: [debugAction])
        return UIMenu(children: [themeMenu, debugMenu])
    }

    private func toggleDebugMode() async {
        let current = await debugProvider.isDebugEnabled
        await debugProvider.setDebugEnabled(!current)
    }

    private func applyDebugMode(isDebugEnabled: Bool, theme: Theme) {
        containerView.setDebugModeEnabled(isDebugEnabled, themeBackground: theme.color.primaryBackground)
        containerView.pagingView.setDebugModeEnabled(isDebugEnabled)
        mainContentView.setDebugModeEnabled(isDebugEnabled)
        pageViewControllers.forEach { viewController in
            (viewController.view as? ScrollablePageView)?.setDebugModeEnabled(isDebugEnabled)
        }
    }

    private func refreshDebugOverlay() {
        let theme = lastTheme ?? .figma
        containerView.setDebugInfo(scrollSnapshot: lastScrollSnapshot, theme: theme)
    }

    private func addChildViewControllers() {
        pageViewControllers.forEach { viewController in
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
    }

    private func handleProgress(_ snapshot: ScrollProgressSnapshot) {
        if hasAppearAnimationCompleted {
            containerView.setGradientProgress(snapshot.overallProgress)
            mainContentView.setVerticalOffsetProgress(snapshot.overallProgress)
            let expansionProgress = snapshot.overallProgress.clamped(to: 0...1)
            mainContentView.updateAppearance(expansionProgress: expansionProgress)
        }
        snapshot.pageProgress.forEach { progressItem in
            guard let updatable = pageAppearanceUpdatables[safe: progressItem.pageIndex] else { return }
            updatable.updateAppearance(progress: progressItem.progress)
        }
        updateFooter(snapshot: snapshot)
    }

    private func setupFooter() {
        containerView.footerView.onContinueTapped = { [weak self] in
            self?.handleContinueTapped()
        }
        skillLevelTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = viewModel.skillLevelStream()
            for await _ in stream {
                refreshFooterState()
                refreshCongratulationsContent()
            }
        }
        refreshFooterState(activePageIndex: 0)
    }

    private func refreshCongratulationsContent() {
        (pageViewControllers.last as? CongratulationsPageViewController)?.refreshContent()
    }

    private func handleContinueTapped() {
        let currentIndex = containerView.pagingView.currentPageIndex
        let nextIndex = min(currentIndex + 1, OnboardingPage.done.rawValue)
        if nextIndex == OnboardingPage.done.rawValue {
            HapticsManager.success()
        } else {
            HapticsManager.medium()
        }
        containerView.pagingView.scrollToPage(nextIndex, animated: true)
    }

    private func updateFooter(snapshot: ScrollProgressSnapshot) {
        let activePage = snapshot.pageProgress.first { $0.isActive }?.pageIndex ?? 0
        let rawProgress = snapshot.progress(forPage: OnboardingPage.done.rawValue)
        let rawProgressToPage1 = snapshot.progress(forPage: OnboardingPage.skillPicker.rawValue)
        let progressToPage1 = snapshot.overallProgress >= 1 ? 1 : rawProgressToPage1
        let progressToFourthScreen = viewModel.progressToFourthScreen(
            snapshotOverallProgress: snapshot.overallProgress,
            rawProgressForPage3: rawProgress
        )
        refreshFooterState(activePageIndex: activePage, progressToFourthScreen: progressToFourthScreen, progressToPage1: progressToPage1)
    }

    private func refreshFooterState(activePageIndex: Int? = nil, progressToFourthScreen: CGFloat? = nil, progressToPage1: CGFloat? = nil) {
        let pageIndex = activePageIndex ?? containerView.pagingView.currentPageIndex
        let footer = containerView.footerView
        let theme = lastTheme ?? .figma

        let progress: CGFloat = viewModel.isLastPageIncluded ? 0 : (progressToFourthScreen ?? 0)

        let welcomeLabelProgress: CGFloat
        if let p = progressToPage1 {
            welcomeLabelProgress = p
        } else {
            welcomeLabelProgress = pageIndex >= OnboardingPage.skillPicker.rawValue ? 1 : 0
        }

        let pageIndicatorSectionHeight = theme.layout.footerPageIndicatorTopMargin + theme.layout.footerPageIndicatorDotSize
        let welcomeLabelSectionHeight = theme.layout.footerWelcomeLabelTopMargin + theme.layout.footerWelcomeLabelHeight + theme.layout.footerWelcomeLabelMarginToButton
        let footerHeight = theme.layout.footerButtonHeight + pageIndicatorSectionHeight + welcomeLabelSectionHeight * (1 - welcomeLabelProgress)
        let footerReservedHeight = (footerHeight + theme.layout.footerBottomPadding) * (1 - progress)

        containerView.setFooterHeight(footerHeight)
        containerView.setFooterReservedHeight(footerReservedHeight)

        if hasAppearAnimationCompleted {
            footer.setWelcomeLabelProgress(welcomeLabelProgress)
            footer.setVisibilityProgress(progress)
        }

        let footerState = viewModel.footerState(for: pageIndex)
        footer.continueButton.title = footerState.title
        footer.continueButton.isEnabled = footerState.isEnabled

        footer.setCurrentPage(pageIndex, totalPages: viewModel.totalPages)

        containerView.pagingView.setLastPageIncluded(viewModel.isLastPageIncluded)
    }
}
