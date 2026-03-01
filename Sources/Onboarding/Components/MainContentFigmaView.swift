import UIKit

public final class MainContentFigmaView: UIView {
    private var accoladeCardView: AccoladeCardView?
    private var theme: Theme?
    private var translationX: CGFloat = 0
    private var verticalOffsetProgress: CGFloat = -1
    private var appearProgress: CGFloat = 1

    private lazy var debugOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.12)
        return overlay
    }()

    private lazy var firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "djay")
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "hero")
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.alpha = 0
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.MainContent.mixMusic
        label.textAlignment = .center
        label.numberOfLines = 2
        label.alpha = 0
        return label
    }()

    private lazy var accoladeContainerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        return container
    }()

    private lazy var expandableStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
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

    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let accolade: Accolade

    public init(accolade: Accolade) {
        self.accolade = accolade
        super.init(frame: .zero)
        buildView()
    }

    public convenience init(accolades: [Accolade]) {
        self.init(accolade: accolades.first ?? Accolade(icon: .trophy, title: "", subtitle: ""))
    }

    required init?(coder: NSCoder) {
        accolade = Accolade(icon: .trophy, title: "", subtitle: "")
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        clipsToBounds = false
        contentStack.clipsToBounds = false

        addSubview(contentStack)
        addSubview(debugOverlay)

        let card = AccoladeCardView()
        card.configure(accolade: accolade)
        accoladeCardView = card
        accoladeContainerView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: accoladeContainerView.topAnchor),
            card.leadingAnchor.constraint(equalTo: accoladeContainerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: accoladeContainerView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: accoladeContainerView.bottomAnchor),
        ])

        expandableStack.addArrangedSubview(secondImageView)
        expandableStack.addArrangedSubview(label)
        expandableStack.addArrangedSubview(accoladeContainerView)

        contentStack.addArrangedSubview(topSpacer)
        contentStack.addArrangedSubview(firstImageView)
        contentStack.addArrangedSubview(expandableStack)
        contentStack.addArrangedSubview(bottomSpacer)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor),
            debugOverlay.topAnchor.constraint(equalTo: topAnchor),
            debugOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        updateExpandableVisibility(progress: 0)
        updateTransform()
    }

    public func updateAppearance(expansionProgress: CGFloat) {
        updateExpandableVisibility(progress: expansionProgress)
    }

    public func setAppearProgress(_ progress: CGFloat) {
        appearProgress = min(max(progress, 0), 1)
        firstImageView.alpha = appearProgress
        topSpacer.alpha = appearProgress
        bottomSpacer.alpha = appearProgress
    }

    public func setVerticalOffsetProgress(_ progress: CGFloat) {
        verticalOffsetProgress = min(1, max(-1, progress))
        updateTransform()
    }

    public func applyScrollTranslation(contentOffsetX: CGFloat, pageWidth: CGFloat) {
        guard pageWidth > 0 else { return }
        let overallProgress = contentOffsetX / pageWidth
        translationX = overallProgress <= 1 ? contentOffsetX : pageWidth
        updateTransform()
    }

    private func updateTransform() {
        let mc = theme?.mainContent ?? Theme.fallback.mainContent
        let rangeEnd = mc.scrollPhaseStartY - mc.verticalOffsetEnd
        let rawMapped = verticalOffsetProgress.map(from: -1...1, to: 0...rangeEnd)
        let translationY: CGFloat
        if verticalOffsetProgress < 0 {
            let normalized = (verticalOffsetProgress + 1)
            let eased = normalized.easeOutBack()
            translationY = mc.scrollPhaseStartY - eased.map(from: 0...1, to: 0...mc.appearPhaseEndY)
        } else {
            translationY = mc.scrollPhaseStartY - rawMapped
        }
        transform = CGAffineTransform(translationX: translationX, y: translationY)
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        debugOverlay.isHidden = !enabled
    }

    private func updateExpandableVisibility(progress: CGFloat) {
        let mc = theme?.mainContent ?? Theme.fallback.mainContent
        let alpha = progress.map(from: 0...1, to: 0...1)
        let scale = mc.labelScaleStart + (1 - mc.labelScaleStart) * progress
        let t = CGAffineTransform(scaleX: scale, y: scale)

        secondImageView.alpha = alpha
        secondImageView.transform = t.translatedBy(x: 0, y: (1 - progress) * mc.expandableTranslationY)
        label.alpha = alpha
        label.transform = t.translatedBy(x: 0, y: (mc.labelScaleStartFactor - progress) * mc.expandableLabelTranslationY)
        accoladeContainerView.alpha = alpha
        accoladeContainerView.transform = t.translatedBy(x: 0, y: (mc.labelScaleStartFactor - progress) * mc.expandableLabelTranslationY)
    }
}

extension MainContentFigmaView: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {}
}

extension MainContentFigmaView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        let spacing = theme.spacing.content
        contentStack.spacing = spacing
        contentStack.layoutMargins = UIEdgeInsets(
            top: theme.margin.inner,
            left: spacing,
            bottom: theme.margin.inner,
            right: spacing
        )
        contentStack.isLayoutMarginsRelativeArrangement = true
        expandableStack.spacing = spacing
        label.applyLargeTitleStyle(theme: theme)
        accoladeCardView?.apply(theme: theme)
    }
}
