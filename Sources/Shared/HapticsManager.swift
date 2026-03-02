import UIKit

class HapticsManager {

    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    static func light() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    static func medium() {
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }

    static func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    static func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
}

