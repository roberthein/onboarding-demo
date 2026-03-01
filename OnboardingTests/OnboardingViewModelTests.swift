import Testing
@testable import Onboarding

/// Tests for `OnboardingViewModel`: skill level selection and state updates.
@MainActor
@Suite("OnboardingViewModel")
struct OnboardingViewModelTests {

    @Test("Initial skill level is nil")
    func initialSkillLevelIsNil() async {
        let vm = OnboardingViewModel()
        #expect(vm.skillLevel == nil)
    }

    @Test("Selecting skill level updates state")
    func selectSkillLevelUpdatesState() async {
        let vm = OnboardingViewModel()
        vm.selectSkillLevel(.intermediate)
        #expect(vm.skillLevel == .intermediate)
    }

    @Test("Skill level can be changed multiple times")
    func skillLevelCanBeChanged() async {
        let vm = OnboardingViewModel()
        vm.selectSkillLevel(.beginner)
        #expect(vm.skillLevel == .beginner)
        vm.selectSkillLevel(.advanced)
        #expect(vm.skillLevel == .advanced)
    }
}
