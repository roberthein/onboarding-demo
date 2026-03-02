import UIKit

@MainActor
public protocol PageAppearanceUpdatable: AnyObject {
    func updateAppearance(progress: CGFloat)
}

@MainActor
public protocol PageContentView: ThemedView, PageAppearanceUpdatable {}
