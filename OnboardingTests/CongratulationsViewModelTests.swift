import Testing
@testable import Onboarding

/// Tests for `CongratulationsViewModel`: title, subtitle, and skill-level-driven text.
@MainActor
@Suite("CongratulationsViewModel")
struct CongratulationsViewModelTests {

    @Test("Title is always Congratulations")
    func titleIsCongratulations() async {
        let vm = OnboardingViewModel()
        let congratsVM = CongratulationsViewModel(onboardingViewModel: vm)
        #expect(congratsVM.titleText == "Congratulations!")
    }

    @Test("Subtitle defaults when no skill selected")
    func subtitleDefaultWhenNoSkill() async {
        let vm = OnboardingViewModel()
        let congratsVM = CongratulationsViewModel(onboardingViewModel: vm)
        #expect(congratsVM.subtitleText == "Let's get started!")
    }

    @Test("Subtitle reflects skill level when selected")
    func subtitleReflectsSkillLevel() async {
        let vm = OnboardingViewModel()
        vm.selectSkillLevel(.beginner)
        let congratsVM = CongratulationsViewModel(onboardingViewModel: vm)
        #expect(congratsVM.subtitleText == SkillLevel.beginner.congratulationSubtitle)
    }

    @Test("Subtitle updates when skill level changes")
    func subtitleUpdatesWithSkillChange() async {
        let vm = OnboardingViewModel()
        vm.selectSkillLevel(.advanced)
        let congratsVM = CongratulationsViewModel(onboardingViewModel: vm)
        #expect(congratsVM.subtitleText == SkillLevel.advanced.congratulationSubtitle)
        vm.selectSkillLevel(.expert)
        #expect(congratsVM.subtitleText == SkillLevel.expert.congratulationSubtitle)
    }
}
