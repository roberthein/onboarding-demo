import UIKit

public enum AppIcon: CaseIterable, Sendable {
    case trophy
    case bolt
    case palette
    case gearshape
    case sunMax
    case moon
    case ant
    case appleLogo

    public var emoji: String {
        switch self {
        case .trophy: return "🏆"
        case .bolt: return "⚡"
        case .palette: return "🎨"
        case .gearshape: return "⚙️"
        case .sunMax: return "☀️"
        case .moon: return "🌙"
        case .ant: return "🐜"
        case .appleLogo: return ""
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .trophy: return "trophy"
        case .bolt: return "bolt"
        case .palette: return "paintpalette"
        case .gearshape: return "gearshape"
        case .sunMax: return "sun.max"
        case .moon: return "moon"
        case .ant: return "ant"
        case .appleLogo: return "apple.logo"
        }
    }

    public func image(theme: Theme) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: theme.icon.small, weight: .regular)
        return UIImage(systemName: sfSymbolName, withConfiguration: config)
    }
}
