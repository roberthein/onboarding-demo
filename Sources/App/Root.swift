import UIKit

@MainActor
public final class Root {

    public let themeProvider: ThemeProvider
    public let debugProvider: DebugProvider
    public let progressCoordinator: ScrollProgressCoordinator
    public let onboardingContainer: OnboardingContainerViewController

    public init() {
        let appTheme: Theme = .figma
        themeProvider = ThemeProvider(initialTheme: appTheme)
        debugProvider = DebugProvider(initialDebugEnabled: false)
        progressCoordinator = ScrollProgressCoordinator()
        onboardingContainer = OnboardingContainerViewController(
            initialTheme: appTheme,
            themeProvider: themeProvider,
            debugProvider: debugProvider,
            progressCoordinator: progressCoordinator
        )
    }
}
