import Testing
@testable import Onboarding

/// Tests for `SkillLevel`: display names and congratulation subtitles.
@MainActor
@Suite("SkillLevel")
struct SkillLevelTests {

    @Test("All cases have display names")
    func allCasesHaveDisplayNames() async {
        SkillLevel.allCases.forEach { level in
            #expect(!level.displayName.isEmpty)
        }
    }

    @Test("Each level has unique congratulation subtitle")
    func uniqueCongratulationsSubtitles() async {
        let subtitles = Set(SkillLevel.allCases.map { $0.congratulationSubtitle })
        #expect(subtitles.count == SkillLevel.allCases.count)
    }

    @Test("Congratulations subtitles are non-empty")
    func congratulationsSubtitlesNonEmpty() async {
        SkillLevel.allCases.forEach { level in
            #expect(!level.congratulationSubtitle.isEmpty)
        }
    }
}
