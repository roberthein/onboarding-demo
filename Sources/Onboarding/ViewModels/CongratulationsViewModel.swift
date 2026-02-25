import Foundation

@MainActor
public final class CongratulationsViewModel {
    private weak var onboardingViewModel: OnboardingViewModel?

    public init(onboardingViewModel: OnboardingViewModel) {
        self.onboardingViewModel = onboardingViewModel
    }

    public var skillLevel: SkillLevel? { onboardingViewModel?.skillLevel }
    public var titleText: String { "Congratulations!" }
    public var subtitleText: String { skillLevel?.congratulationSubtitle ?? "Let's get started!" }
}
