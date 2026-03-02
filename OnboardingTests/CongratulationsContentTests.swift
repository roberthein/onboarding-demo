import Testing
@testable import Onboarding

@MainActor
@Suite("CongratulationsContent")
struct CongratulationsContentTests {

    @Test("Title is always Congratulations")
    func titleIsCongratulations() async {
        #expect(CongratulationsContent.title == LocalizedStrings.Congratulations.title)
    }

    @Test("Subtitle defaults when no skill selected")
    func subtitleDefaultWhenNoSkill() async {
        let subtitle = CongratulationsContent.subtitle(for: nil)
        #expect(subtitle == LocalizedStrings.Congratulations.defaultSubtitle)
    }

    @Test("Subtitle reflects skill level when selected")
    func subtitleReflectsSkillLevel() async {
        let subtitle = CongratulationsContent.subtitle(for: .beginner)
        #expect(subtitle == SkillLevel.beginner.congratulationSubtitle)
    }

    @Test("Subtitle updates when skill level changes")
    func subtitleUpdatesWithSkillChange() async {
        #expect(CongratulationsContent.subtitle(for: .advanced) == SkillLevel.advanced.congratulationSubtitle)
        #expect(CongratulationsContent.subtitle(for: .intermediate) == SkillLevel.intermediate.congratulationSubtitle)
    }
}
