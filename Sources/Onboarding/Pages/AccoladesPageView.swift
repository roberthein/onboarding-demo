import UIKit

public final class AccoladesPageView: ScrollablePageView {
    private var accoladeViews: [AccoladeCardView] = []

    private lazy var stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Theme.figma.spacing.item
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let accolades: [Accolade]

    public init(accolades: [Accolade]) {
        self.accolades = accolades
        super.init(frame: .zero)
        setupContent()
    }

    required init?(coder: NSCoder) {
        accolades = []
        super.init(coder: coder)
        setupContent()
    }

    private func setupContent() {
        accolades.forEach { accolade in
            let card = AccoladeCardView()
            card.configure(accolade: accolade)
            accoladeViews.append(card)
            stack.addArrangedSubview(card)
        }
        centeredContentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])
    }
}

extension AccoladesPageView: PageContentView {
    public func apply(theme: Theme) {
        accoladeViews.forEach { $0.apply(theme: theme) }
    }
}

extension AccoladesPageView {
    public func updateAppearance(progress: CGFloat) {
        accoladeViews.enumerated().forEach { index, card in
            card.alpha = progress
        }
    }
}
