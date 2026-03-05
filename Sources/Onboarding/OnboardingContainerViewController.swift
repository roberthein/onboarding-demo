import UIKit

private let appearAnimationDurationMultiplier: TimeInterval = 3

public final class OnboardingContainerViewController: UIViewController {
    private let initialTheme: Theme
    private let themeProvider: ThemeProviding
    private let debugProvider: DebugProviding
    private let progressCoordinator: ScrollProgressCoordinator
    private let viewModel: OnboardingViewModel

    private var progressTask: Task<Void, Never>?
    private var themeTask: Task<Void, Never>?
    private var debugTask: Task<Void, Never>?
    private var skillLevelTask: Task<Void, Never>?
    private var lastTheme: Theme
    private var lastScrollSnapshot: ScrollProgressSnapshot?
    private var hasAppearAnimationCompleted = false
    private var appearAnimator: DisplayLinkAnimator?
    private var appearAnimationTask: Task<Void, Never>?

    private lazy var mainContentPageView: MainContentPageView = {
        let view = MainContentPageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var accoladesPageView: AccoladesPageView = {
        let view = AccoladesPageView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var skillPickerPageView: SkillPickerPageView = {
        let view = SkillPickerPageView()
        view.backgroundColor = .clear
        view.setSelected(viewModel.skillLevel)
        return view
    }()

    private lazy var congratulationsPageView: CongratulationsPageView = {
        let view = CongratulationsPageView()
        view.backgroundColor = .clear
        view.configure(title: CongratulationsContent.title, subtitle: CongratulationsContent.subtitle(for: viewModel.skillLevel), skillLevel: viewModel.skillLevel)
        return view
    }()

    private var pageAppearanceUpdatables: [Int: PageAppearanceUpdatable] {
        [2: skillPickerPageView, 3: congratulationsPageView]
    }

    private var scrollTranslationApplicables: [ScrollTranslationApplicable] {
        [skillPickerPageView]
    }

    private var scrollablePages: [ScrollablePageView] {
        [mainContentPageView, accoladesPageView, skillPickerPageView, congratulationsPageView]
    }

    private var containerView: OnboardingContainerView {
        view as! OnboardingContainerView
    }

    public init(
        initialTheme: Theme,
        themeProvider: ThemeProviding,
        debugProvider: DebugProviding,
        progressCoordinator: ScrollProgressCoordinator
    ) {
        self.initialTheme = initialTheme
        self.themeProvider = themeProvider
        self.debugProvider = debugProvider
        self.progressCoordinator = progressCoordinator
        self.viewModel = OnboardingViewModel()
        self.lastTheme = initialTheme
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
        applyThemeUpdates(theme: initialTheme, isDebugEnabled: false)

        skillPickerPageView.onPickerSelect = { [weak self] level in
            self?.skillPickerPageView.setSelected(level, animate: true)
            self?.viewModel.selectSkillLevel(level)
        }

        let pageHosts: [UIView] = [mainContentPageView, accoladesPageView, skillPickerPageView, congratulationsPageView]
        containerView.pagedScrollView.configure(numberOfPages: viewModel.totalPages, pageViews: pageHosts)
        containerView.pagedScrollView.onScroll = { [weak self] scrollView in
            guard let self else { return }
            let contentOffsetX = scrollView.contentOffset.x
            let pageWidth = scrollView.bounds.width > 0
                ? scrollView.bounds.width
                : containerView.pagedScrollView.bounds.width
            guard pageWidth > 0 else { return }
            scrollTranslationApplicables.forEach { $0.applyScrollTranslation(contentOffsetX: contentOffsetX, pageWidth: pageWidth) }
        }

        progressCoordinator.connect(to: containerView.pagedScrollView.progressStream())

        setupFooter()

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
        let theme = lastTheme
        let duration = theme.motion.duration * appearAnimationDurationMultiplier
        let startTime = CACurrentMediaTime()
        containerView.setGradientProgress(-1)
        mainContentPageView.setAppearProgress(0)
        containerView.footerView.setAppearProgress(0)
        containerView.pagedScrollView.scrollView.isScrollEnabled = false

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
            mainContentPageView.setAppearProgress(normalizedProgress)
            mainContentPageView.updateAppearance(progress: 0)
            mainContentPageView.setVerticalOffsetProgress(progress)
            let appearAnimation = theme.appearAnimation
            let footerProgress = max(0, (normalizedProgress - appearAnimation.footerStartT) / (appearAnimation.footerEndT - appearAnimation.footerStartT))
            containerView.footerView.setAppearProgress(footerProgress)

            if normalizedProgress >= 1 {
                appearAnimator = nil
                hasAppearAnimationCompleted = true
                containerView.pagedScrollView.scrollView.isScrollEnabled = true
                if let snapshot = lastScrollSnapshot {
                    containerView.setGradientProgress(snapshot.overallProgress)
                    mainContentPageView.setVerticalOffsetProgress(snapshot.overallProgress)
                    let expansionProgress = snapshot.overallProgress.clamped(to: 0...1)
                    mainContentPageView.updateAppearance(progress: expansionProgress)
                } else {
                    mainContentPageView.updateAppearance(progress: 0)
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
        let savedPageIndex = containerView.pagedScrollView.currentPageIndex
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self else { return }
            view.setNeedsLayout()
            view.layoutIfNeeded()
            scrollablePages.forEach { $0.refreshScrollableLayout() }
            containerView.pagedScrollView.scrollToPage(savedPageIndex, animated: false)
        }, completion: { [weak self] _ in
            guard let self else { return }
            view.setNeedsLayout()
            view.layoutIfNeeded()
            scrollablePages.forEach { $0.refreshScrollableLayout() }
            containerView.pagedScrollView.scrollToPage(savedPageIndex, animated: false)
        })
    }

    private func setupThemeStream() {
        themeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                let isThemeChange = lastTheme != theme
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
        containerView.setLastPageShaderSpeedMultiplier(SkillLevel.lasersSpeedMultiplier(for: viewModel.skillLevel))
        applyDebugMode(isDebugEnabled: isDebugEnabled, theme: theme)
        containerView.apply(theme: theme)
        mainContentPageView.apply(theme: theme)
        skillPickerPageView.apply(theme: theme)
        congratulationsPageView.apply(theme: theme)
        if let snapshot = lastScrollSnapshot {
            let congratsProgress = snapshot.progress(forPage: OnboardingPage.done.rawValue)
            skillPickerPageView.setCongratsPageProgress(congratsProgress)
            containerView.setDecibelOverlay(visible: congratsProgress > 0, skillLevel: viewModel.skillLevel, progress: congratsProgress)
            containerView.setLastPageShaderProgress(lastPageShaderProgress(from: snapshot))
        } else {
            containerView.setLastPageShaderProgress(0)
        }
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
        containerView.pagedScrollView.setDebugModeEnabled(isDebugEnabled)
        mainContentPageView.setDebugModeEnabled(isDebugEnabled)
        accoladesPageView.setDebugModeEnabled(isDebugEnabled)
        skillPickerPageView.setDebugModeEnabled(isDebugEnabled)
        congratulationsPageView.setDebugModeEnabled(isDebugEnabled)
    }

    private func refreshDebugOverlay() {
        containerView.setDebugInfo(scrollSnapshot: lastScrollSnapshot, theme: lastTheme)
    }

    private func handleProgress(_ snapshot: ScrollProgressSnapshot) {
        if hasAppearAnimationCompleted {
            containerView.setGradientProgress(snapshot.overallProgress)
            mainContentPageView.setVerticalOffsetProgress(snapshot.overallProgress)
            let expansionProgress = snapshot.overallProgress.clamped(to: 0...1)
            mainContentPageView.updateAppearance(progress: expansionProgress)
        }
        snapshot.pageProgress.forEach { progressItem in
            guard let updatable = pageAppearanceUpdatables[progressItem.pageIndex] else { return }
            updatable.updateAppearance(progress: progressItem.progress)
        }
        let congratsProgress = snapshot.progress(forPage: OnboardingPage.done.rawValue)
        skillPickerPageView.setCongratsPageProgress(congratsProgress)
        containerView.setDecibelOverlay(
            visible: congratsProgress > 0,
            skillLevel: viewModel.skillLevel,
            progress: congratsProgress
        )
        containerView.setLastPageShaderProgress(lastPageShaderProgress(from: snapshot))
        updateFooter(snapshot: snapshot)
    }

    private func lastPageShaderProgress(from snapshot: ScrollProgressSnapshot) -> CGFloat {
        guard viewModel.isLastPageIncluded else { return 0 }
        let doneProgress = snapshot.progress(forPage: OnboardingPage.done.rawValue)
        return ((doneProgress - 0.5) / 0.5).clamped(to: 0...1)
    }

    private func setupFooter() {
        containerView.footerView.onContinueTapped = { [weak self] in
            self?.handleContinueTapped()
        }
        skillLevelTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = viewModel.skillLevelStream()
            for await _ in stream {
                containerView.setLastPageShaderSpeedMultiplier(SkillLevel.lasersSpeedMultiplier(for: viewModel.skillLevel))
                refreshFooterState()
                refreshCongratulationsContent()
            }
        }
        refreshFooterState(activePageIndex: 0)
    }

    private func refreshCongratulationsContent() {
        congratulationsPageView.configure(title: CongratulationsContent.title, subtitle: CongratulationsContent.subtitle(for: viewModel.skillLevel), skillLevel: viewModel.skillLevel)
    }

    private func handleContinueTapped() {
        let currentIndex = containerView.pagedScrollView.currentPageIndex
        let nextIndex = min(currentIndex + 1, OnboardingPage.done.rawValue)
        if nextIndex == OnboardingPage.done.rawValue {
            HapticsManager.success()
        } else {
            HapticsManager.medium()
        }
        containerView.pagedScrollView.scrollToPage(nextIndex, animated: true)
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
        let pageIndex = activePageIndex ?? containerView.pagedScrollView.currentPageIndex
        let footer = containerView.footerView
        let theme = lastTheme

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

        containerView.pagedScrollView.setLastPageIncluded(viewModel.isLastPageIncluded)
    }
}
