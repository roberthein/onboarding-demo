import Foundation

@MainActor
public final class OnboardingViewModel: Sendable {
    public private(set) var skillLevel: SkillLevel? {
        didSet { onSkillLevelChanged?(skillLevel) }
    }

    public var onSkillLevelChanged: (@Sendable (SkillLevel?) -> Void)?

    public init() {}

    public func selectSkillLevel(_ level: SkillLevel?) {
        skillLevel = level
    }
}
