import UIKit

public final class CongratulationsPageViewController: UIViewController {
    private let themeProvider: ThemeProviding
    private let viewModel: CongratulationsViewModel
    private var themeTask: Task<Void, Never>?

    private var contentView: CongratulationsPageView {
        view as! CongratulationsPageView
    }

    public init(themeProvider: ThemeProviding, viewModel: CongratulationsViewModel) {
        self.themeProvider = themeProvider
        self.viewModel = viewModel
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
        let contentView = CongratulationsPageView()
        contentView.configure(title: viewModel.titleText, subtitle: viewModel.subtitleText)
        view = contentView
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

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.configure(title: viewModel.titleText, subtitle: viewModel.subtitleText)
    }

    public func refreshContent() {
        contentView.configure(title: viewModel.titleText, subtitle: viewModel.subtitleText)
    }
}

extension CongratulationsPageViewController: ThemedView {
    public func apply(theme: Theme) {
        contentView.apply(theme: theme)
    }
}

extension CongratulationsPageViewController: PageAppearanceUpdatable {
    public func updateAppearance(progress: CGFloat) {
        contentView.updateAppearance(progress: progress)
    }
}
