import UIKit

public class ScrollablePageView: UIView {
    private var isDebugModeEnabled: Bool = false

    private lazy var pageDebugOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        return overlay
    }()

    private lazy var scrollViewDebugOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        return overlay
    }()

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var topSpacer: UIView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        return spacer
    }()

    private lazy var bottomSpacer: UIView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        return spacer
    }()

    private lazy var contentDebugOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        return overlay
    }()

    public lazy var centeredContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentHuggingPriority(.required, for: .vertical)
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
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
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(topSpacer)
        contentStack.addArrangedSubview(centeredContentView)
        contentStack.addArrangedSubview(bottomSpacer)
        addSubview(pageDebugOverlay)
        addSubview(scrollViewDebugOverlay)
        centeredContentView.addSubview(contentDebugOverlay)
        scrollView.backgroundColor = .clear
        centeredContentView.backgroundColor = .clear
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        NSLayoutConstraint.activate([
            topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageDebugOverlay.topAnchor.constraint(equalTo: topAnchor),
            pageDebugOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageDebugOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageDebugOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollViewDebugOverlay.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewDebugOverlay.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewDebugOverlay.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewDebugOverlay.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentDebugOverlay.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            contentDebugOverlay.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor),
            contentDebugOverlay.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor),
            contentDebugOverlay.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            contentGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameGuide.heightAnchor),
        ])
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        isDebugModeEnabled = enabled
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        centeredContentView.backgroundColor = .clear
        pageDebugOverlay.isHidden = !enabled
        scrollViewDebugOverlay.isHidden = !enabled
        contentDebugOverlay.isHidden = !enabled
    }
}
