import UIKit

/// Root object that wires together app infrastructure and the onboarding container.
@MainActor
public final class Root {

    /// Provides theme switching and reactive theme updates.
    public let themeProvider: ThemeProvider

    /// Provides debug mode state and updates.
    public let debugProvider: DebugProvider

    /// Coordinates scroll progress from the paging container to page views.
    public let progressCoordinator: ScrollProgressCoordinator

    /// Main onboarding container view controller. Install as root view controller.
    public let onboardingContainer: OnboardingContainerViewController

    /// Creates the root with all dependencies configured.
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
