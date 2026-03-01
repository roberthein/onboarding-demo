import UIKit

@MainActor
public final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    public var window: UIWindow?
    private var root: Root?

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let rootInstance = Root()
        root = rootInstance

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        window.rootViewController = rootInstance.onboardingContainer
        window.makeKeyAndVisible()

        self.window = window
    }
}
