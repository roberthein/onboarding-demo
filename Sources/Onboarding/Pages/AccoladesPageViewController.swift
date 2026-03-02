import UIKit

public final class AccoladesPageViewController: UIViewController {

    let themeProvider: ThemeProviding
    private var themeTask: Task<Void, Never>?

    private var contentView: AccoladesPageView {
        view as! AccoladesPageView
    }

    public init(themeProvider: ThemeProviding) {
        self.themeProvider = themeProvider
        super.init(nibName: nil, bundle: nil)
        themeTask = startThemeSubscription()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = AccoladesPageView(accolades: DefaultAccolades.accolades)
    }

    deinit {
        themeTask?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        applyInitialTheme()
    }
}

extension AccoladesPageViewController: ThemeSubscribing {}

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
