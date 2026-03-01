import Foundation

public enum SkillLevel: String, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    public var displayName: String {
        switch self {
        case .beginner: return LocalizedStrings.SkillLevel.beginner
        case .intermediate: return LocalizedStrings.SkillLevel.intermediate
        case .advanced: return LocalizedStrings.SkillLevel.advanced
        }
    }

    public var congratulationSubtitle: String {
        switch self {
        case .beginner: return LocalizedStrings.SkillLevel.beginnerCongrats
        case .intermediate: return LocalizedStrings.SkillLevel.intermediateCongrats
        case .advanced: return LocalizedStrings.SkillLevel.advancedCongrats
        }
    }

    public var faceImageName: String {
        switch self {
        case .beginner: return "dj-face-beginner"
        case .intermediate: return "dj-face-intermediate"
        case .advanced: return "dj-face-pro"
        }
    }
}
