import UIKit

public final class MainContentView: UIView {
    private var accoladeCardView: AccoladeCardView?
    private var theme: Theme?
    private var translationX: CGFloat = 0
    private var verticalOffsetProgress: CGFloat = -1
    private var appearProgress: CGFloat = 1

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
        installDebugOverlay(tintColor: UIColor.systemTeal.withAlphaComponent(0.12))

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
        ])

        updateExpandableVisibility(progress: 0)
        updateTransform()
    }

    public func updateAppearance(expansionProgress: CGFloat) {
        updateExpandableVisibility(progress: expansionProgress)
    }

    public func setAppearProgress(_ progress: CGFloat) {
        appearProgress = progress.clamped(to: 0...1)
        firstImageView.alpha = appearProgress
        topSpacer.alpha = appearProgress
        bottomSpacer.alpha = appearProgress
    }

    public func setVerticalOffsetProgress(_ progress: CGFloat) {
        verticalOffsetProgress = progress.clamped(to: -1...1)
        updateTransform()
    }

    private func updateTransform() {
        let mainContent = theme?.mainContent ?? Theme.fallback.mainContent
        let rangeEnd = mainContent.scrollPhaseStartY - mainContent.verticalOffsetEnd
        let rawMapped = verticalOffsetProgress.map(from: -1...1, to: 0...rangeEnd)
        let translationY: CGFloat
        if verticalOffsetProgress < 0 {
            let normalized = (verticalOffsetProgress + 1)
            let eased = normalized.easeOutBack()
            translationY = mainContent.scrollPhaseStartY - eased.map(from: 0...1, to: 0...mainContent.appearPhaseEndY)
        } else {
            translationY = mainContent.scrollPhaseStartY - rawMapped
        }
        transform = CGAffineTransform(translationX: translationX, y: translationY)
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        setDebugOverlayVisible(enabled)
    }

    private func updateExpandableVisibility(progress: CGFloat) {
        let mainContent = theme?.mainContent ?? Theme.fallback.mainContent
        let alpha = progress.map(from: 0...1, to: 0...1)
        let scale = mainContent.labelScaleStart + (1 - mainContent.labelScaleStart) * progress
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)

        secondImageView.alpha = alpha
        secondImageView.transform = scaleTransform.translatedBy(x: 0, y: (1 - progress) * mainContent.expandableTranslationY)
        label.alpha = alpha
        label.transform = scaleTransform.translatedBy(x: 0, y: (mainContent.labelScaleStartFactor - progress) * mainContent.expandableLabelTranslationY)
        accoladeContainerView.alpha = alpha
        accoladeContainerView.transform = scaleTransform.translatedBy(x: 0, y: (mainContent.labelScaleStartFactor - progress) * mainContent.expandableLabelTranslationY)
    }
}

extension MainContentView: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {}
}

extension MainContentView: ScrollTranslationApplicable {

    public func applyScrollTranslation(contentOffsetX: CGFloat, pageWidth: CGFloat) {
        guard pageWidth > 0 else { return }
        let overallProgress = contentOffsetX / pageWidth
        translationX = overallProgress <= 1 ? contentOffsetX : pageWidth
        updateTransform()
    }
}

extension MainContentView: ThemedView {
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
