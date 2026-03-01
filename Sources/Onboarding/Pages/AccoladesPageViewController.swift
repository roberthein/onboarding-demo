import UIKit

public final class AccoladesPageViewController: UIViewController {
    static let defaultAccolades: [Accolade] = [
        Accolade(icon: .trophy, title: LocalizedStrings.Accolades.provenQuality, subtitle: LocalizedStrings.Accolades.provenQualitySubtitle),
        Accolade(icon: .bolt, title: LocalizedStrings.Accolades.performanceFirst, subtitle: LocalizedStrings.Accolades.performanceFirstSubtitle),
        Accolade(icon: .palette, title: LocalizedStrings.Accolades.beautifulDesign, subtitle: LocalizedStrings.Accolades.beautifulDesignSubtitle),
    ]

    private let themeProvider: ThemeProviding
    private var themeTask: Task<Void, Never>?

    private var accolades: [Accolade] { Self.defaultAccolades }

    private var contentView: AccoladesPageView {
        view as! AccoladesPageView
    }

    public init(themeProvider: ThemeProviding) {
        self.themeProvider = themeProvider
        super.init(nibName: nil, bundle: nil)
        themeTask = Task { @MainActor [weak weakSelf = self] in
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                guard let weakSelf else { return }
                weakSelf.apply(theme: theme)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = AccoladesPageView(accolades: accolades)
    }

    deinit {
        themeTask?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        Task { @MainActor [weak weakSelf = self] in
            guard let weakSelf else { return }
            let currentTheme = await themeProvider.currentTheme
            weakSelf.contentView.apply(theme: currentTheme)
        }
    }
}

extension AccoladesPageViewController: ThemedView {
    public func apply(theme: Theme) {
        contentView.apply(theme: theme)
    }
}

extension AccoladesPageViewController: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        contentView.updateAppearance(progress: progress)
    }
}
