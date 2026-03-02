import UIKit

public typealias ScrollProgressHandler = @Sendable (ScrollProgressSnapshot) -> Void

public final class PagingScrollContainerView: UIView {
    private var progressHandler: ScrollProgressHandler?
    private var progressContinuation: AsyncStream<ScrollProgressSnapshot>.Continuation?
    private var numberOfPages: Int = 0
    private var lastHapticPageIndex: Int = -1
    private var pageWidth: CGFloat { bounds.width }
    private var isDebugModeEnabled: Bool = false
    private var isLastPageIncluded: Bool = false
    private var pageContainers: [UIView] = []

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
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
        buildView()
    }

    private func buildView() {
        backgroundColor = .clear
        addSubview(scrollView)
        addSubview(debugOverlay)
        scrollView.addSubview(contentStack)
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            debugOverlay.topAnchor.constraint(equalTo: topAnchor),
            debugOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            contentStack.heightAnchor.constraint(equalTo: frameGuide.heightAnchor),
        ])
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        isDebugModeEnabled = enabled
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        debugOverlay.isHidden = !enabled
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    public func configure(numberOfPages: Int, pageViews: [UIView]) {
        precondition(pageViews.count == numberOfPages, "Page count mismatch")
        self.numberOfPages = numberOfPages
        pageContainers = []
        contentStack.arrangedSubviews.forEach { contentStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        for (index, view) in pageViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.clipsToBounds = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
            pageContainers.append(container)
            if index < numberOfPages - 1 {
                contentStack.addArrangedSubview(container)
            }
        }
        let frameGuide = scrollView.frameLayoutGuide
        let widthConstraints = (0 ..< min(pageContainers.count, numberOfPages - 1)).map { i in
            pageContainers[i].widthAnchor.constraint(equalTo: frameGuide.widthAnchor)
        }
        NSLayoutConstraint.activate(widthConstraints)
        isLastPageIncluded = false
    }

    public func onProgress(_ handler: @escaping ScrollProgressHandler) {
        progressHandler = handler
    }

    public func progressStream() -> AsyncStream<ScrollProgressSnapshot> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            progressContinuation = continuation
            let ref = WeakSendable(self)
            continuation.onTermination = { _ in
                Task { @MainActor in
                    ref.value?.progressContinuation = nil
                }
            }
        }
    }

    public var onScroll: ((UIScrollView) -> Void)?

    public var shouldAllowScrollToPage: ((Int) -> Bool)?

    public func setLastPageIncluded(_ included: Bool) {
        guard isLastPageIncluded != included else { return }
        isLastPageIncluded = included
        updateLastPageVisibility()
    }

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
        progressContinuation?.yield(snapshot)
    }

    deinit {
        progressContinuation?.finish()
    }

    private func updateLastPageVisibility() {
        guard numberOfPages > 0 else { return }
        let lastContainer = pageContainers[numberOfPages - 1]
        let lastIsInStack = contentStack.arrangedSubviews.contains(lastContainer)

        if isLastPageIncluded {
            if !lastIsInStack {
                contentStack.addArrangedSubview(lastContainer)
                NSLayoutConstraint.activate([
                    lastContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                ])
            }
        } else {
            if lastIsInStack {
                contentStack.removeArrangedSubview(lastContainer)
                lastContainer.removeFromSuperview()
                let width = max(1, scrollView.bounds.width)
                if width > 0 {
                    let maxPage = numberOfPages - 2
                    let maxOffset = CGFloat(max(0, maxPage)) * width
                    if scrollView.contentOffset.x > maxOffset {
                        scrollView.contentOffset.x = maxOffset
                    }
                }
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        reportProgress()
    }
}

extension PagingScrollContainerView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reportProgress()
        firePageSnapHapticIfNeeded()
        onScroll?(scrollView)
    }

    private func firePageSnapHapticIfNeeded() {
        let page = currentPageIndex
        guard page != lastHapticPageIndex else { return }
        lastHapticPageIndex = page
        HapticsManager.light()
    }
}

