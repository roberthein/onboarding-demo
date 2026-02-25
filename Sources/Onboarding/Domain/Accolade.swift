import Foundation

public struct Accolade: Sendable {
    public let icon: AppIcon
    public let title: String
    public let subtitle: String

    public init(icon: AppIcon, title: String, subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}
