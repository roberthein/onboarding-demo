import UIKit

public class ScrollablePageView: UIView {
    private var isDebugModeEnabled: Bool = false

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
        installDebugOverlay(tintColor: UIColor.systemGreen.withAlphaComponent(0.12))
        scrollView.installDebugOverlay(tintColor: UIColor.systemBlue.withAlphaComponent(0.12))
        centeredContentView.installDebugOverlay(tintColor: UIColor.systemOrange.withAlphaComponent(0.15))
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
        setDebugOverlayVisible(enabled)
        scrollView.setDebugOverlayVisible(enabled)
        centeredContentView.setDebugOverlayVisible(enabled)
    }
}
