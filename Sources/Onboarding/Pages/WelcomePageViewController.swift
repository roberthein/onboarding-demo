import UIKit

public final class WelcomePageViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private var themeTask: Task<Void, Never>?

    private var contentView: WelcomePageView {
        view as! WelcomePageView
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
        view = WelcomePageView()
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

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.updateAppearance(progress: 1)
    }
}

extension WelcomePageViewController: ThemedView {
    public func apply(theme: Theme) {
        contentView.apply(theme: theme)
    }
}

extension WelcomePageViewController: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        contentView.updateAppearance(progress: progress)
    }
}
