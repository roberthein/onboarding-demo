import UIKit

private final class AppearAnimationContext {
    let startTime: CFTimeInterval
    let duration: CFTimeInterval
    init(startTime: CFTimeInterval, duration: CFTimeInterval) {
        self.startTime = startTime
        self.duration = duration
    }
}

public final class OnboardingContainerViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private let debugProvider: DebugProviding
    private let progressCoordinator: ScrollProgressCoordinator
    private let viewModel: OnboardingViewModel
    private var mainContentView: MainContentFigmaView!
    private var pageViewControllers: [UIViewController] = []
    private var pageAppearanceUpdatables: [PageAppearanceUpdatable] = []
    private var progressTask: Task<Void, Never>?
    private var themeTask: Task<Void, Never>?
    private var debugTask: Task<Void, Never>?
    private var lastThemeId: String?
    private var lastTheme: Theme?
    private var lastScrollSnapshot: ScrollProgressSnapshot?
    private var hasAppearAnimationCompleted = false
    private var appearDisplayLink: CADisplayLink?

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

        let congratsViewModel = CongratulationsViewModel(onboardingViewModel: viewModel)
        mainContentView = MainContentFigmaView(
            accolade: Accolade(icon: .appleLogo, title: LocalizedStrings.MainContent.appleDesignAward, subtitle: LocalizedStrings.MainContent.winner)
        )
        let accolades = AccoladesPageViewController(themeProvider: themeProvider)
        let skillPicker = SkillPickerPageViewController(themeProvider: themeProvider, viewModel: viewModel)
        let congrats = CongratulationsPageViewController(themeProvider: themeProvider, viewModel: congratsViewModel)

        pageViewControllers = [accolades, skillPicker, congrats]
        pageAppearanceUpdatables = [mainContentView, accolades, skillPicker, congrats]
        addChildViewControllers()
        pageViewControllers.forEach { $0.loadViewIfNeeded() }
        let pageHosts: [UIView] = [mainContentView] + pageViewControllers.map { $0.view! }
        containerView.pagingView.configure(numberOfPages: 4, pageViews: pageHosts)
        containerView.pagingView.onScroll = { [weak self] scrollView in
            guard let self else { return }
            let contentOffsetX = scrollView.contentOffset.x
            let pageWidth = scrollView.bounds.width > 0
                ? scrollView.bounds.width
                : self.containerView.pagingView.bounds.width
            guard pageWidth > 0 else { return }
            self.mainContentView.applyScrollTranslation(contentOffsetX: contentOffsetX, pageWidth: pageWidth)
        }

        containerView.pagingView.onProgress { [progressCoordinator] snapshot in
            Task { await progressCoordinator.report(snapshot) }
        }

        setupFooter()

        lastTheme = .figma
        lastThemeId = Theme.fallback.id
        applyThemeUpdates(theme: .figma, isDebugEnabled: false)

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
            await refreshAll()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAppearAnimation()
    }

    deinit {
        appearDisplayLink?.invalidate()
        progressTask?.cancel()
        themeTask?.cancel()
        debugTask?.cancel()
    }

    private func runAppearAnimation() {
        guard !hasAppearAnimationCompleted else { return }
        let theme = lastTheme ?? .figma
        let duration = theme.motion.duration * 3
        let startTime = CACurrentMediaTime()
        containerView.setGradientProgress(-1)
        mainContentView.setAppearProgress(0)
        containerView.footerView.setAppearProgress(0)
        containerView.pagingView.scrollView.isScrollEnabled = false

        let displayLink = CADisplayLink(target: self, selector: #selector(appearAnimationTick(_:)))
        displayLink.add(to: .main, forMode: .common)
        appearDisplayLink = displayLink
        objc_setAssociatedObject(displayLink, &Self.displayLinkKey, AppearAnimationContext(startTime: startTime, duration: duration), .OBJC_ASSOCIATION_RETAIN)
    }

    private static var displayLinkKey: UInt8 = 0

    @objc private func appearAnimationTick(_ link: CADisplayLink) {
        guard let context = objc_getAssociatedObject(link, &Self.displayLinkKey) as? AppearAnimationContext else { return }
        let elapsed = CACurrentMediaTime() - context.startTime
        let rawT = min(1, elapsed / context.duration)
        let t = rawT.easeInOut()
        let progress = -1 + t
        containerView.setGradientProgress(progress)
        mainContentView.setAppearProgress(t)
        mainContentView.updateAppearance(expansionProgress: 0)
        mainContentView.setVerticalOffsetProgress(progress)
        let theme = lastTheme ?? .figma
        let anim = theme.appearAnimation
        let footerT = max(0, (t - anim.footerStartT) / (anim.footerEndT - anim.footerStartT))
        containerView.footerView.setAppearProgress(footerT)

        if t >= 1 {
            link.invalidate()
            appearDisplayLink = nil
            hasAppearAnimationCompleted = true
            containerView.pagingView.scrollView.isScrollEnabled = true
            if let snapshot = lastScrollSnapshot {
                containerView.setGradientProgress(snapshot.overallProgress)
                mainContentView.setVerticalOffsetProgress(snapshot.overallProgress)
                let expansionProgress = min(1, max(0, snapshot.overallProgress))
                mainContentView.updateAppearance(expansionProgress: expansionProgress)
            } else {
                mainContentView.updateAppearance(expansionProgress: 0)
            }
            refreshFooterState()
        }
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
            for await _ in stream {
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
        pageViewControllers.forEach { vc in
            (vc.view as? ScrollablePageView)?.setDebugModeEnabled(isDebugEnabled)
        }
    }

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
        if hasAppearAnimationCompleted {
            containerView.setGradientProgress(snapshot.overallProgress)
            mainContentView.setVerticalOffsetProgress(snapshot.overallProgress)
            let expansionProgress = min(1, max(0, snapshot.overallProgress))
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
        viewModel.onSkillLevelChanged = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshFooterState()
                (self?.pageViewControllers.last as? CongratulationsPageViewController)?.refreshContent()
            }
        }
        refreshFooterState(activePageIndex: 0)
    }

    private func handleContinueTapped() {
        let currentIndex = containerView.pagingView.currentPageIndex
        let nextIndex = min(currentIndex + 1, 3)
        if nextIndex == 3 {
            HapticsManager.success()
        } else {
            HapticsManager.medium()
        }
        containerView.pagingView.scrollToPage(nextIndex, animated: true)
    }

    private func updateFooter(snapshot: ScrollProgressSnapshot) {
        let activePage = snapshot.pageProgress.first { $0.isActive }?.pageIndex ?? 0
        let rawProgress = snapshot.progress(forPage: 3)
        let rawProgressToPage1 = snapshot.progress(forPage: 1)
        let progressToPage1 = snapshot.overallProgress >= 1 ? 1 : rawProgressToPage1
        let lastVisiblePageIndex = viewModel.skillLevel != nil ? 3 : 2
        let progressToFourthScreen: CGFloat
        if snapshot.overallProgress >= CGFloat(lastVisiblePageIndex) {
            progressToFourthScreen = viewModel.skillLevel != nil ? 1 : 0
        } else {
            progressToFourthScreen = rawProgress
        }
        refreshFooterState(activePageIndex: activePage, progressToFourthScreen: progressToFourthScreen, progressToPage1: progressToPage1)
    }

    private func refreshFooterState(activePageIndex: Int? = nil, progressToFourthScreen: CGFloat? = nil, progressToPage1: CGFloat? = nil) {
        let pageIndex = activePageIndex ?? containerView.pagingView.currentPageIndex
        let footer = containerView.footerView
        let theme = lastTheme ?? .figma

        let progress: CGFloat
        if viewModel.skillLevel != nil {
            progress = 0
        } else if let p = progressToFourthScreen {
            progress = p
        } else {
            progress = 0
        }

        let welcomeLabelProgress: CGFloat
        if let p = progressToPage1 {
            welcomeLabelProgress = p
        } else {
            welcomeLabelProgress = pageIndex >= 1 ? 1 : 0
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

        let title: String
        let isEnabled: Bool
        switch pageIndex {
        case 0, 1:
            title = LocalizedStrings.Footer.continueTitle
            isEnabled = true
        case 2:
            title = LocalizedStrings.Footer.letsGo
            isEnabled = viewModel.skillLevel != nil
        case 3:
            title = LocalizedStrings.Footer.done
            isEnabled = true
        default:
            title = LocalizedStrings.Footer.continueTitle
            isEnabled = true
        }

        footer.continueButton.title = title
        footer.continueButton.isEnabled = isEnabled

        footer.setCurrentPage(pageIndex, totalPages: 4)

        containerView.pagingView.setLastPageIncluded(viewModel.skillLevel != nil)
    }
}
