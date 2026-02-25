import Foundation

public enum SkillLevel: String, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    public var displayName: String { rawValue }

    public var congratulationSubtitle: String {
        switch self {
        case .beginner: return "Start with the basics and build your skills step by step."
        case .intermediate: return "You're ready to explore more advanced techniques."
        case .advanced: return "Challenge yourself with complex projects."
        case .expert: return "You're set to master the most demanding workflows."
        }
    }
}
