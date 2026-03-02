import UIKit

public final class OnboardingContainerView: UIView {

    public lazy var gradientBackgroundView: GradientBackgroundView = {
        let view = GradientBackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var pagingView: PagingScrollContainerView = {
        let pagingScrollView = PagingScrollContainerView()
        pagingScrollView.translatesAutoresizingMaskIntoConstraints = false
        return pagingScrollView
    }()

    private lazy var settingsMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.isUserInteractionEnabled = true
        return button
    }()

    private let debugDefaultValue = "—"

    private lazy var debugOverlay: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = debugDefaultValue
        return label
    }()

    private lazy var debugTintOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemRed.withAlphaComponent(0.06)
        return overlay
    }()

    private lazy var debugOverlayContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerCurve = .continuous
        container.layer.masksToBounds = true
        container.isHidden = true
        return container
    }()

    private var isDebugModeEnabled: Bool = false
    private var pagingBottomConstraint: NSLayoutConstraint?
    private var debugOverlayTopConstraint: NSLayoutConstraint?
    private var debugOverlayLeadingConstraint: NSLayoutConstraint?
    private var debugOverlayTrailingConstraint: NSLayoutConstraint?
    private var debugOverlayBottomConstraint: NSLayoutConstraint?
    private var footerViewLeadingConstraint: NSLayoutConstraint?
    private var footerViewTrailingConstraint: NSLayoutConstraint?
    private var footerViewBottomConstraint: NSLayoutConstraint?
    private var footerViewHeightConstraint: NSLayoutConstraint?
    private var settingsMenuTopConstraint: NSLayoutConstraint?
    private var settingsMenuTrailingConstraint: NSLayoutConstraint?
    private var settingsMenuWidthConstraint: NSLayoutConstraint?
    private var settingsMenuHeightConstraint: NSLayoutConstraint?
    private var debugOverlayContainerTopConstraint: NSLayoutConstraint?
    private var debugOverlayContainerLeadingConstraint: NSLayoutConstraint?

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
        addSubview(pagingView)
        addSubview(footerView)
        addSubview(debugTintOverlay)
        addSubview(settingsMenuButton)
        addSubview(debugOverlayContainer)
        debugOverlayContainer.addSubview(debugOverlay)
        debugOverlayTopConstraint = debugOverlay.topAnchor.constraint(equalTo: debugOverlayContainer.topAnchor, constant: 0)
        debugOverlayLeadingConstraint = debugOverlay.leadingAnchor.constraint(equalTo: debugOverlayContainer.leadingAnchor, constant: 0)
        debugOverlayTrailingConstraint = debugOverlay.trailingAnchor.constraint(equalTo: debugOverlayContainer.trailingAnchor, constant: 0)
        debugOverlayBottomConstraint = debugOverlay.bottomAnchor.constraint(equalTo: debugOverlayContainer.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            debugOverlayTopConstraint!, debugOverlayLeadingConstraint!, debugOverlayTrailingConstraint!, debugOverlayBottomConstraint!,
        ])
        bringSubviewToFront(debugTintOverlay)
        bringSubviewToFront(footerView)
        bringSubviewToFront(settingsMenuButton)
        bringSubviewToFront(debugOverlayContainer)
        let pagingBottom = pagingView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        pagingBottomConstraint = pagingBottom
        footerViewLeadingConstraint = footerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0)
        footerViewTrailingConstraint = footerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
        footerViewBottomConstraint = footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        footerViewHeightConstraint = footerView.heightAnchor.constraint(equalToConstant: Theme.fallback.layout.footerTotalHeight)
        settingsMenuTopConstraint = settingsMenuButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
        settingsMenuTrailingConstraint = settingsMenuButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
        settingsMenuWidthConstraint = settingsMenuButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        settingsMenuHeightConstraint = settingsMenuButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        debugOverlayContainerTopConstraint = debugOverlayContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
        debugOverlayContainerLeadingConstraint = debugOverlayContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            debugTintOverlay.topAnchor.constraint(equalTo: topAnchor),
            debugTintOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugTintOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugTintOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            pagingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            pagingView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            pagingView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            pagingBottom,
            footerViewLeadingConstraint!, footerViewTrailingConstraint!, footerViewBottomConstraint!, footerViewHeightConstraint!,
            settingsMenuTopConstraint!, settingsMenuTrailingConstraint!, settingsMenuWidthConstraint!, settingsMenuHeightConstraint!,
            debugOverlayContainerTopConstraint!, debugOverlayContainerLeadingConstraint!,
        ])
    }

    public func setGradientProgress(_ progress: CGFloat) {
        gradientBackgroundView.setProgress(progress)
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
        debugTintOverlay.isHidden = !enabled
        pagingView.setDebugModeEnabled(enabled)
    }

    public func setDebugInfo(scrollSnapshot: ScrollProgressSnapshot?, theme: Theme) {
        let show = isDebugModeEnabled
        debugOverlayContainer.isHidden = !show

        debugOverlay.applyDebugStyle(theme: theme)
        debugOverlayContainer.backgroundColor = theme.color.debugOverlayBackground

        guard show else { return }

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
        debugOverlay.text = lines.joined(separator: "\n")
    }
}

extension OnboardingContainerView: ThemedView {
    public func apply(theme: Theme) {
        backgroundColor = .clear
        gradientBackgroundView.setColors(primary: theme.color.gradientPrimaryBackground, secondary: theme.color.gradientSecondaryBackground)
        debugOverlayContainer.backgroundColor = theme.color.debugOverlayBackground
        debugOverlayContainer.layer.cornerRadius = theme.radius.small
        let padding = theme.layout.debugOverlayPadding
        debugOverlayTopConstraint?.constant = padding
        debugOverlayLeadingConstraint?.constant = padding
        debugOverlayTrailingConstraint?.constant = -padding
        debugOverlayBottomConstraint?.constant = -padding
        footerViewLeadingConstraint?.constant = theme.layout.footerHorizontalPadding
        footerViewTrailingConstraint?.constant = -theme.layout.footerHorizontalPadding
        footerViewBottomConstraint?.constant = -theme.layout.footerBottomPadding
        footerViewHeightConstraint?.constant = theme.layout.footerTotalHeight
        settingsMenuTopConstraint?.constant = theme.margin.inner
        settingsMenuTrailingConstraint?.constant = -theme.margin.outer
        settingsMenuWidthConstraint?.constant = theme.layout.buttonHeight
        settingsMenuHeightConstraint?.constant = theme.layout.buttonHeight
        debugOverlayContainerTopConstraint?.constant = theme.layout.debugOverlayMargin
        debugOverlayContainerLeadingConstraint?.constant = theme.layout.debugOverlayMargin
        footerView.apply(theme: theme)
        setFooterReservedHeight(theme.layout.footerTotalHeight + theme.layout.footerBottomPadding)
    }
}
