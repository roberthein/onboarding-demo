import UIKit

/// Application delegate. Handles app lifecycle and scene configuration.
@main
@MainActor
public final class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Called when the app finishes launching. Performs minimal setup.
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    /// Provides scene configuration for the given session. Connects scenes to `SceneDelegate`.
    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }
}
