import UIKit

public class ScrollablePageView: UIView, ThemedView {
    private var isDebugModeEnabled: Bool = false
    private var themeContinuation: AsyncStream<Theme>.Continuation?
    private(set) var currentTheme: Theme?
    private var contentContainerMinHeightConstraint: NSLayoutConstraint?

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    public lazy var centeredContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentHuggingPriority(.required, for: .vertical)
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        return contentView
    }()

    private lazy var contentContainerView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
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
        backgroundColor = .clear
        addSubview(scrollView)
        scrollView.addSubview(contentContainerView)
        contentContainerView.addSubview(centeredContentView)
        installDebugOverlay(tintColor: UIColor.systemGreen.withAlphaComponent(0.12))
        scrollView.installDebugOverlay(tintColor: UIColor.systemBlue.withAlphaComponent(0.12))
        centeredContentView.installDebugOverlay(tintColor: UIColor.systemOrange.withAlphaComponent(0.15))
        scrollView.backgroundColor = .clear
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        contentContainerMinHeightConstraint = contentContainerView.heightAnchor.constraint(greaterThanOrEqualTo: frameGuide.heightAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentContainerView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            contentContainerView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            contentContainerMinHeightConstraint!,
            centeredContentView.topAnchor.constraint(greaterThanOrEqualTo: contentContainerView.topAnchor),
            centeredContentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            centeredContentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            centeredContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentContainerView.bottomAnchor),
            centeredContentView.centerYAnchor.constraint(equalTo: contentContainerView.centerYAnchor),
            centeredContentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
        ])
        updateInsetAwareLayout()
    }

    private func updateInsetAwareLayout() {
        let verticalInsets = scrollView.contentInset.top + scrollView.contentInset.bottom
        contentContainerMinHeightConstraint?.constant = -verticalInsets
    }

    public func refreshScrollableLayout() {
        updateInsetAwareLayout()
        setNeedsLayout()
        layoutIfNeeded()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        isDebugModeEnabled = enabled
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        setDebugOverlayVisible(enabled)
        scrollView.setDebugOverlayVisible(enabled)
        centeredContentView.setDebugOverlayVisible(enabled)
    }

    public func apply(theme: Theme) {
        currentTheme = theme
        scrollView.contentInset.top = theme.margin.outer
        scrollView.contentInset.bottom = theme.margin.outer
        updateInsetAwareLayout()
        themeContinuation?.yield(theme)
    }

    public func themeStream() -> AsyncStream<Theme> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            themeContinuation = continuation
            if let currentTheme {
                continuation.yield(currentTheme)
            }
            let ref = WeakSendable(self)
            continuation.onTermination = { _ in
                Task { @MainActor in
                    ref.value?.themeContinuation = nil
                }
            }
        }
    }

    deinit {
        themeContinuation?.finish()
    }
}
