import UIKit

@MainActor
public protocol ThemedView: AnyObject {
    func apply(theme: Theme)
}
