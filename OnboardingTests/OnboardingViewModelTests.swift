import Foundation
import Testing
@testable import Onboarding

@MainActor
@Suite("OnboardingViewModel")
struct OnboardingViewModelTests {

    @Test("Initial skill level is nil")
    func initialSkillLevelIsNil() async {
        let viewModel = OnboardingViewModel()
        #expect(viewModel.skillLevel == nil)
    }

    @Test("Selecting skill level updates state")
    func selectSkillLevelUpdatesState() async {
        let viewModel = OnboardingViewModel()
        viewModel.selectSkillLevel(.intermediate)
        #expect(viewModel.skillLevel == .intermediate)
    }

    @Test("Skill level can be changed multiple times")
    func skillLevelCanBeChanged() async {
        let viewModel = OnboardingViewModel()
        viewModel.selectSkillLevel(.beginner)
        #expect(viewModel.skillLevel == .beginner)
        viewModel.selectSkillLevel(.advanced)
        #expect(viewModel.skillLevel == .advanced)
    }

    @Test("Last visible page is congrats when skill selected")
    func lastVisiblePageWhenSkillSelected() async {
        let viewModel = OnboardingViewModel()
        #expect(viewModel.lastVisiblePageIndex == OnboardingPage.congratulations.rawValue)
        #expect(viewModel.isLastPageIncluded == false)

        viewModel.selectSkillLevel(.beginner)
        #expect(viewModel.lastVisiblePageIndex == OnboardingPage.done.rawValue)
        #expect(viewModel.isLastPageIncluded == true)
    }

    @Test("Footer state for accolades and skill picker pages")
    func footerStateForAccoladesAndSkillPicker() async {
        let viewModel = OnboardingViewModel()
        let accoladesState = viewModel.footerState(for: OnboardingPage.accolades.rawValue)
        let skillPickerState = viewModel.footerState(for: OnboardingPage.skillPicker.rawValue)

        #expect(accoladesState.title == LocalizedStrings.Footer.continueTitle)
        #expect(accoladesState.isEnabled == true)
        #expect(skillPickerState.title == LocalizedStrings.Footer.continueTitle)
        #expect(skillPickerState.isEnabled == true)
    }

    @Test("Footer state for congratulations page depends on skill level")
    func footerStateForCongratulations() async {
        let viewModel = OnboardingViewModel()
        var state = viewModel.footerState(for: OnboardingPage.congratulations.rawValue)
        #expect(state.title == LocalizedStrings.Footer.letsGo)
        #expect(state.isEnabled == false)

        viewModel.selectSkillLevel(.intermediate)
        state = viewModel.footerState(for: OnboardingPage.congratulations.rawValue)
        #expect(state.isEnabled == true)
    }

    @Test("Footer state for done page")
    func footerStateForDone() async {
        let viewModel = OnboardingViewModel()
        let state = viewModel.footerState(for: OnboardingPage.done.rawValue)
        #expect(state.title == LocalizedStrings.Footer.done)
        #expect(state.isEnabled == true)
    }

    @Test("Progress to fourth screen when skill selected")
    func progressToFourthScreen() async {
        let viewModel = OnboardingViewModel()
        let progressNoSkill = viewModel.progressToFourthScreen(snapshotOverallProgress: 2.5, rawProgressForPage3: 0.5)
        #expect(progressNoSkill == 0)

        viewModel.selectSkillLevel(.beginner)
        let progressWithSkill = viewModel.progressToFourthScreen(snapshotOverallProgress: 3, rawProgressForPage3: 0)
        #expect(progressWithSkill == 1)
    }
}
