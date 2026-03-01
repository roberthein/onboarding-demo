import UIKit

@MainActor
public final class Root {

    public let themeProvider: ThemeProvider
    public let debugProvider: DebugProvider
    public let progressCoordinator: ScrollProgressCoordinator
    public let onboardingContainer: OnboardingContainerViewController

    public init() {
        themeProvider = ThemeProvider(initialTheme: .figma)
        debugProvider = DebugProvider(initialDebugEnabled: false)
        progressCoordinator = ScrollProgressCoordinator()
        onboardingContainer = OnboardingContainerViewController(
            themeProvider: themeProvider,
            debugProvider: debugProvider,
            progressCoordinator: progressCoordinator
        )
    }
}
