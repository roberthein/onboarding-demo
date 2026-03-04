import UIKit

public final class MainContentPageView: ScrollablePageView {
    private var verticalOffsetProgress: CGFloat = -1
    private var theme: Theme?

    private lazy var mainContent: MainContentView = {
        let view = MainContentView(
            accolade: Accolade(icon: .appleLogo, title: LocalizedStrings.MainContent.appleDesignAward, subtitle: LocalizedStrings.MainContent.winner)
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init() {
        super.init(frame: .zero)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        scrollView.clipsToBounds = false
        centeredContentView.addSubview(mainContent)
        NSLayoutConstraint.activate([
            mainContent.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            mainContent.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor),
            mainContent.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor),
            mainContent.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])

        updateTransform()
    }

    public func setAppearProgress(_ progress: CGFloat) {
        mainContent.setAppearProgress(progress)
    }

    public func setVerticalOffsetProgress(_ progress: CGFloat) {
        verticalOffsetProgress = progress.clamped(to: -1...0)
        updateTransform()
    }

    private func updateTransform() {
        guard let theme else { return }
        let mainContent = theme.mainContent
        let eased = verticalOffsetProgress.easeOutBack().clamped(to: -1...0)
        let translationY: CGFloat = mainContent.verticalOffset - eased.map(from: -1...0, to: 0...mainContent.verticalOffset)
        transform = CGAffineTransform(translationX: 0, y: translationY)
    }
}

extension MainContentPageView: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        mainContent.updateAppearance(progress: progress)
    }
}

extension MainContentPageView: ScrollTranslationApplicable {

    public func applyScrollTranslation(contentOffsetX: CGFloat, pageWidth: CGFloat) {
    }
}

extension MainContentPageView: ThemedView {
    public func apply(theme: Theme) {
        mainContent.apply(theme: theme)
        self.theme = theme
        updateTransform()
    }
}
