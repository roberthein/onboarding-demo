import UIKit

public final class AccoladesPageView: ScrollablePageView {
    private var accoladeViews: [AccoladeCardView] = []

    private lazy var stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let accolades: [Accolade]

    public init(accolades: [Accolade]) {
        self.accolades = accolades
        super.init(frame: .zero)
        buildView()
    }

    required init?(coder: NSCoder) {
        accolades = []
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {}
}

extension AccoladesPageView: PageContentView {
    public func apply(theme: Theme) {
        stack.spacing = theme.spacing.item
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
