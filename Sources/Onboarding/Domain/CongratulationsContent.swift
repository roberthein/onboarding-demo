import Foundation

public enum CongratulationsContent {

    public static let title = LocalizedStrings.Congratulations.title

    public static func subtitle(for skillLevel: SkillLevel?) -> String {
        skillLevel?.congratulationSubtitle ?? LocalizedStrings.Congratulations.defaultSubtitle
    }
}
