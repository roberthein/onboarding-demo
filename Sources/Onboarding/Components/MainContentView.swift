import UIKit

public final class MainContentView: UIView {
    private var accoladeCardView: AccoladeCardView?
    private var theme: Theme?
    private var appearProgress: CGFloat = 1
    private var expansionProgress: CGFloat = 0
    private var compactConstraints: [NSLayoutConstraint] = []
    private var expandedConstraints: [NSLayoutConstraint] = []
    private var expansionAnimator: UIViewPropertyAnimator?
    private var isExpandedLayoutActive: Bool = false

    private lazy var firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.image = UIImage(named: "djay")
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
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

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(contentView)
        contentView.addSubview(firstImageView)
        contentView.addSubview(secondImageView)
        contentView.addSubview(label)
        contentView.addSubview(accoladeContainerView)
        installDebugOverlay(tintColor: UIColor.systemTeal.withAlphaComponent(0.12))

        let card = AccoladeCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(accolade: accolade)
        accoladeCardView = card
        accoladeContainerView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: accoladeContainerView.topAnchor),
            card.leadingAnchor.constraint(equalTo: accoladeContainerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: accoladeContainerView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: accoladeContainerView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            firstImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            firstImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            secondImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            accoladeContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            accoladeContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        rebuildExpansionConstraints()
        updateExpandableVisibility(progress: 0)
    }

    public func setAppearProgress(_ progress: CGFloat) {
        appearProgress = progress.clamped(to: 0...1)
        firstImageView.alpha = appearProgress
    }

    public func setDebugModeEnabled(_ enabled: Bool) {
        setDebugOverlayVisible(enabled)
    }

    private func updateExpandableVisibility(progress: CGFloat) {
        expansionProgress = progress.clamped(to: 0...1)
        let alpha = expansionProgress.map(from: 0...1 , to: -1...1)

        secondImageView.alpha = alpha
        label.alpha = alpha
        accoladeContainerView.alpha = alpha
        updateExpansionAnimationProgress()
    }

    private func activateCompactLayout() {
        guard isExpandedLayoutActive else { return }
        NSLayoutConstraint.deactivate(expandedConstraints)
        NSLayoutConstraint.activate(compactConstraints)
        isExpandedLayoutActive = false
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func makeExpansionAnimatorIfNeeded() {
        guard expansionAnimator == nil, theme != nil, !expandedConstraints.isEmpty else { return }
        layoutIfNeeded()
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear) { [weak self] in
            guard let self else { return }
            if isExpandedLayoutActive {
                NSLayoutConstraint.deactivate(self.expandedConstraints)
                NSLayoutConstraint.activate(self.compactConstraints)
                isExpandedLayoutActive = false
            } else {
                NSLayoutConstraint.deactivate(self.compactConstraints)
                NSLayoutConstraint.activate(self.expandedConstraints)
                isExpandedLayoutActive = true
            }

            self.layoutIfNeeded()
        }
        animator.startAnimation()
        animator.pauseAnimation()
        expansionAnimator = animator
    }

    private func updateExpansionAnimationProgress() {
        guard theme != nil else {
            expansionAnimator?.stopAnimation(true)
            expansionAnimator = nil
            activateCompactLayout()
            return
        }
        if expansionProgress <= 0.001 {
            expansionAnimator?.stopAnimation(true)
            expansionAnimator = nil
            activateCompactLayout()
            return
        }
        makeExpansionAnimatorIfNeeded()
        expansionAnimator?.fractionComplete = expansionProgress
    }

    private func rebuildExpansionConstraints() {
        NSLayoutConstraint.deactivate(compactConstraints + expandedConstraints)
        expansionAnimator?.stopAnimation(true)
        expansionAnimator = nil
        isExpandedLayoutActive = false

        compactConstraints = [
            firstImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(compactConstraints)

        // Keep a valid intrinsic height before the first theme arrives.
        guard let theme else {
            return
        }

        expandedConstraints = [
            firstImageView.bottomAnchor.constraint(equalTo: secondImageView.topAnchor, constant: -theme.margin.outer),
            secondImageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -theme.margin.outer),
            label.bottomAnchor.constraint(equalTo: accoladeContainerView.topAnchor, constant: -theme.margin.outer),
            accoladeContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
    }
}

extension MainContentView: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        updateExpandableVisibility(progress: progress)
    }
}

extension MainContentView: ThemedView {
    public func apply(theme: Theme) {
        self.theme = theme
        rebuildExpansionConstraints()
        label.applyLargeTitleStyle(theme: theme)
        accoladeCardView?.apply(theme: theme)
        updateExpandableVisibility(progress: expansionProgress)
    }
}
