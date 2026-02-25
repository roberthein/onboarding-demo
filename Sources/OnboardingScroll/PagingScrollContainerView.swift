import UIKit

public typealias ScrollProgressHandler = @Sendable (ScrollProgressSnapshot) -> Void

public final class PagingScrollContainerView: UIView {
    private var progressHandler: ScrollProgressHandler?
    private var numberOfPages: Int = 0
    private var pageWidth: CGFloat { bounds.width }
    private var isDebugModeEnabled: Bool = false

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        addSubview(debugOverlay)
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            debugOverlay.topAnchor.constraint(equalTo: topAnchor),
            debugOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
        return scrollView
    }()

    private lazy var debugOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        return overlay
    }()

    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        _ = scrollView
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        isDebugModeEnabled = enabled
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        debugOverlay.isHidden = !enabled
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _ = scrollView
    }

    public func configure(numberOfPages: Int, pageViews: [UIView]) {
        precondition(pageViews.count == numberOfPages, "Page count mismatch")
        self.numberOfPages = numberOfPages
        contentStack.arrangedSubviews.forEach { contentStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        pageViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
            contentStack.addArrangedSubview(container)
        }
        contentStack.arrangedSubviews.forEach { view in
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }

    public func onProgress(_ handler: @escaping ScrollProgressHandler) {
        progressHandler = handler
    }

    /// When set, invoked before a scroll ends to allow or deny scrolling to a given page index.
    public var shouldAllowScrollToPage: ((Int) -> Bool)?

    public var currentPageIndex: Int {
        let pageWidth = max(1, scrollView.bounds.width)
        let offset = scrollView.contentOffset.x
        let index = Int(round(offset / pageWidth))
        return max(0, min(index, numberOfPages - 1))
    }

    public func scrollToPage(_ index: Int, animated: Bool) {
        guard (0 ..< numberOfPages).contains(index) else { return }
        layoutIfNeeded()
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let offset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }

    private func reportProgress() {
        let pageWidth = max(1, scrollView.bounds.width)
        let offset = scrollView.contentOffset.x
        let overall = offset / pageWidth
        let roundedPageIndex = Int(round(overall))
        let lastPageIndex = Swift.max(0, numberOfPages - 1)
        let activeIndex = Swift.max(0, Swift.min(roundedPageIndex, lastPageIndex))
        let pageProgress: [PageProgress] = (0 ..< numberOfPages).map { index in
            let pageCenter = CGFloat(index) * pageWidth + pageWidth / 2
            let viewportCenter = offset + pageWidth / 2
            let distance = abs(viewportCenter - pageCenter)
            let rawProgress = max(0, 1 - distance / pageWidth)
            let progress = min(1, max(0, rawProgress))
            return PageProgress(pageIndex: index, progress: progress, isActive: index == activeIndex)
        }
        let snapshot = ScrollProgressSnapshot(overallProgress: overall, pageProgress: pageProgress)
        progressHandler?(snapshot)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        reportProgress()
    }
}

extension PagingScrollContainerView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reportProgress()
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let shouldAllow = shouldAllowScrollToPage else { return }
        let pageWidth = max(1, scrollView.bounds.width)
        let targetPage = Int(round(targetContentOffset.pointee.x / pageWidth))
        guard !shouldAllow(targetPage) else { return }
        let fallbackPage = max(0, targetPage - 1)
        targetContentOffset.pointee.x = CGFloat(fallbackPage) * pageWidth
    }
}

