import UIKit

protocol ThemeSubscribing: ThemedView, AnyObject {
    var themeProvider: ThemeProviding { get }
}

extension ThemeSubscribing where Self: UIViewController {
    func startThemeSubscription() -> Task<Void, Never> {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await themeProvider.themeStream()
            for await theme in stream {
                apply(theme: theme)
            }
        }
    }

    func applyInitialTheme() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let currentTheme = await themeProvider.currentTheme
            apply(theme: currentTheme)
        }
    }
}
