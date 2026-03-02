import UIKit

public final class OnboardingContainerView: UIView {

    public lazy var gradientBackgroundView: GradientBackgroundView = {
        let view = GradientBackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var pagedScrollView: PagedScrollView = {
        let view = PagedScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var settingsMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.isUserInteractionEnabled = true
        return button
    }()

    private let debugDefaultValue = "—"
    private var isDebugModeEnabled: Bool = false
    private var pagingBottomConstraint: NSLayoutConstraint?
    private var footerViewLeadingConstraint: NSLayoutConstraint?
    private var footerViewTrailingConstraint: NSLayoutConstraint?
    private var footerViewBottomConstraint: NSLayoutConstraint?
    private var footerViewHeightConstraint: NSLayoutConstraint?
    private var settingsMenuTopConstraint: NSLayoutConstraint?
    private var settingsMenuTrailingConstraint: NSLayoutConstraint?
    private var settingsMenuWidthConstraint: NSLayoutConstraint?
    private var settingsMenuHeightConstraint: NSLayoutConstraint?

    public lazy var footerView: FooterView = { FooterView() }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        addSubview(gradientBackgroundView)
        addSubview(pagedScrollView)
        addSubview(footerView)
        addSubview(settingsMenuButton)
        installDebugOverlayWithInfo(tintColor: UIColor.systemRed.withAlphaComponent(0.06))
        bringSubviewToFront(footerView)
        bringSubviewToFront(settingsMenuButton)
        let pagingBottom = pagedScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        pagingBottomConstraint = pagingBottom
        footerViewLeadingConstraint = footerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0)
        footerViewTrailingConstraint = footerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
        footerViewBottomConstraint = footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        footerViewHeightConstraint = footerView.heightAnchor.constraint(equalToConstant: Theme.fallback.layout.footerTotalHeight)
        settingsMenuTopConstraint = settingsMenuButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
        settingsMenuTrailingConstraint = settingsMenuButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
        settingsMenuWidthConstraint = settingsMenuButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        settingsMenuHeightConstraint = settingsMenuButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pagedScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            pagedScrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            pagedScrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            pagingBottom,
            footerViewLeadingConstraint!, footerViewTrailingConstraint!, footerViewBottomConstraint!, footerViewHeightConstraint!,
            settingsMenuTopConstraint!, settingsMenuTrailingConstraint!, settingsMenuWidthConstraint!, settingsMenuHeightConstraint!,
        ])
    }

    public func setGradientProgress(_ progress: CGFloat) {
        gradientBackgroundView.setProgress(progress)
    }

    public func setDecibelOverlay(visible: Bool, skillLevel: SkillLevel?, progress: CGFloat) {
        gradientBackgroundView.setDecibelOverlay(visible: visible, skillLevel: skillLevel, progress: visible ? progress : 0)
    }

    public func setFooterReservedHeight(_ height: CGFloat) {
        pagingBottomConstraint?.constant = -height
    }

    public func setFooterHeight(_ height: CGFloat) {
        footerViewHeightConstraint?.constant = height
    }

    public func setSettingsMenu(_ menu: UIMenu, image: UIImage?, tintColor: UIColor) {
        settingsMenuButton.menu = menu
        settingsMenuButton.setImage(image, for: .normal)
        settingsMenuButton.setTitle(nil, for: .normal)
        settingsMenuButton.tintColor = tintColor
    }

    public func setDebugModeEnabled(_ enabled: Bool, themeBackground: UIColor) {
        isDebugModeEnabled = enabled
        backgroundColor = .clear
        setDebugOverlayVisible(enabled)
        pagedScrollView.setDebugModeEnabled(enabled)
    }

    public func setDebugInfo(scrollSnapshot: ScrollProgressSnapshot?, theme: Theme) {
        setDebugOverlayVisible(isDebugModeEnabled)
        var lines: [String] = []
        lines.append("Theme: \(theme.id)")
        if let snap = scrollSnapshot {
            lines.append("Scroll: \(String(format: "%.2f", snap.overallProgress))")
            let perPage = snap.pageProgress
                .sorted { $0.pageIndex < $1.pageIndex }
                .map { "P\($0.pageIndex):\(String(format: "%.2f", $0.progress))\($0.isActive ? "*" : "")" }
                .joined(separator: " ")
            lines.append(perPage)
        } else {
            lines.append("Scroll: \(debugDefaultValue)")
            lines.append("P0:\(debugDefaultValue) P1:\(debugDefaultValue) P2:\(debugDefaultValue) P3:\(debugDefaultValue)")
        }
        updateDebugOverlayInfo(lines.joined(separator: "\n"), theme: theme)
    }
}

extension OnboardingContainerView: ThemedView {
    public func apply(theme: Theme) {
        backgroundColor = .clear
        gradientBackgroundView.setColors(primary: theme.color.gradientPrimaryBackground, secondary: theme.color.gradientSecondaryBackground)
        footerViewLeadingConstraint?.constant = theme.layout.footerHorizontalPadding
        footerViewTrailingConstraint?.constant = -theme.layout.footerHorizontalPadding
        footerViewBottomConstraint?.constant = -theme.layout.footerBottomPadding
        footerViewHeightConstraint?.constant = theme.layout.footerTotalHeight
        settingsMenuTopConstraint?.constant = theme.margin.inner
        settingsMenuTrailingConstraint?.constant = -theme.margin.outer
        settingsMenuWidthConstraint?.constant = theme.layout.buttonHeight
        settingsMenuHeightConstraint?.constant = theme.layout.buttonHeight
        footerView.apply(theme: theme)
        setFooterReservedHeight(theme.layout.footerTotalHeight + theme.layout.footerBottomPadding)
    }
}
