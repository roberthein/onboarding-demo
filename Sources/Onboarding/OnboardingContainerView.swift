import UIKit

public final class OnboardingContainerView: UIView {
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
        label.applyDebugStyle(theme: .figma)
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
        let defaultTheme = Theme.figma
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = defaultTheme.color.debugOverlayBackground
        container.layer.cornerRadius = defaultTheme.radius.small
        container.layer.cornerCurve = .continuous
        container.layer.masksToBounds = true
        container.isHidden = true
        container.addSubview(debugOverlay)
        NSLayoutConstraint.activate([
            debugOverlay.topAnchor.constraint(equalTo: container.topAnchor, constant: defaultTheme.layout.debugOverlayPadding),
            debugOverlay.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: defaultTheme.layout.debugOverlayPadding),
            debugOverlay.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -defaultTheme.layout.debugOverlayPadding),
            debugOverlay.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -defaultTheme.layout.debugOverlayPadding),
        ])
        return container
    }()

    private var isDebugModeEnabled: Bool = false
    private var pagingBottomConstraint: NSLayoutConstraint?

    public lazy var footerView: FooterView = {
        let footer = FooterView()
        return footer
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        let defaultTheme = Theme.figma
        backgroundColor = defaultTheme.color.primaryBackground
        addSubview(pagingView)
        addSubview(footerView)
        addSubview(debugTintOverlay)
        addSubview(settingsMenuButton)
        addSubview(debugOverlayContainer)
        footerView.apply(theme: defaultTheme)
        setFooterReservedHeight(defaultTheme.layout.footerButtonHeight + defaultTheme.layout.footerBottomPadding)
        NSLayoutConstraint.activate([
            debugTintOverlay.topAnchor.constraint(equalTo: topAnchor),
            debugTintOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugTintOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugTintOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        bringSubviewToFront(debugTintOverlay)
        bringSubviewToFront(footerView)
        bringSubviewToFront(settingsMenuButton)
        bringSubviewToFront(debugOverlayContainer)
        let pagingBottom = pagingView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        pagingBottomConstraint = pagingBottom
        NSLayoutConstraint.activate([
            pagingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            pagingView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            pagingView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            pagingBottom,
            footerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: defaultTheme.layout.footerHorizontalPadding),
            footerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -defaultTheme.layout.footerHorizontalPadding),
            footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -defaultTheme.layout.footerBottomPadding),
            footerView.heightAnchor.constraint(equalToConstant: defaultTheme.layout.footerButtonHeight),
            settingsMenuButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: defaultTheme.margin.inner),
            settingsMenuButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: defaultTheme.margin.outer),
            settingsMenuButton.widthAnchor.constraint(greaterThanOrEqualToConstant: defaultTheme.layout.buttonHeight),
            settingsMenuButton.heightAnchor.constraint(greaterThanOrEqualToConstant: defaultTheme.layout.buttonHeight),
            debugOverlayContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: defaultTheme.layout.debugOverlayMargin),
            debugOverlayContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -defaultTheme.layout.debugOverlayMargin),
        ])
    }

    /// Reserves space at the bottom for the footer. Use 0 when footer is hidden.
    public func setFooterReservedHeight(_ height: CGFloat) {
        pagingBottomConstraint?.constant = -height
    }

    // MARK: Settings Menu

    public func setSettingsMenu(_ menu: UIMenu, image: UIImage?, tintColor: UIColor) {
        settingsMenuButton.menu = menu
        settingsMenuButton.setImage(image, for: .normal)
        settingsMenuButton.setTitle(nil, for: .normal)
        settingsMenuButton.tintColor = tintColor
    }

    // MARK: Debug Mode

    public func setDebugModeEnabled(_ enabled: Bool, themeBackground: UIColor? = nil) {
        isDebugModeEnabled = enabled
        backgroundColor = themeBackground ?? Theme.figma.color.primaryBackground
        debugTintOverlay.isHidden = !enabled
        pagingView.setDebugModeEnabled(enabled)
    }

    public func setDebugInfo(themeId: String?, scrollSnapshot: ScrollProgressSnapshot?, theme: Theme) {
        let show = isDebugModeEnabled && (themeId != nil || scrollSnapshot != nil)
        debugOverlayContainer.isHidden = !show

        debugOverlay.applyDebugStyle(theme: theme)
        debugOverlayContainer.backgroundColor = theme.color.debugOverlayBackground

        guard show else { return }

        var lines: [String] = []
        lines.append("Theme: \(themeId ?? debugDefaultValue)")
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
