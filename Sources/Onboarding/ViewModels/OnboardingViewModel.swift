import Foundation

@MainActor
@Observable
public final class OnboardingViewModel {

    public private(set) var skillLevel: SkillLevel? {
        didSet { skillLevelContinuation?.yield(skillLevel) }
    }

    private var skillLevelContinuation: AsyncStream<SkillLevel?>.Continuation?

    public init() {}

    public func skillLevelStream() -> AsyncStream<SkillLevel?> {
        AsyncStream { [weak self] continuation in
            guard let viewModel = self else { return }
            continuation.yield(viewModel.skillLevel)
            viewModel.skillLevelContinuation = continuation
            let ref = WeakSendable(viewModel)
            continuation.onTermination = { _ in
                Task { @MainActor in
                    ref.value?.skillLevelContinuation = nil
                }
            }
        }
    }

    public func selectSkillLevel(_ level: SkillLevel?) {
        skillLevel = level
    }

    public var lastVisiblePageIndex: Int {
        hasSkillLevelSelected ? OnboardingPage.done.rawValue : OnboardingPage.congratulations.rawValue
    }

    public var isLastPageIncluded: Bool {
        hasSkillLevelSelected
    }

    public var totalPages: Int { OnboardingPage.totalPageCount }

    private var hasSkillLevelSelected: Bool { skillLevel != nil }

    public struct FooterState {
        public let title: String
        public let isEnabled: Bool

        public init(title: String, isEnabled: Bool) {
            self.title = title
            self.isEnabled = isEnabled
        }
    }

    public func footerState(for pageIndex: Int) -> FooterState {
        switch OnboardingPage(rawValue: pageIndex) {
        case .accolades, .skillPicker:
            return FooterState(title: LocalizedStrings.Footer.continueTitle, isEnabled: true)
        case .congratulations:
            return FooterState(title: LocalizedStrings.Footer.letsGo, isEnabled: hasSkillLevelSelected)
        case .done:
            return FooterState(title: LocalizedStrings.Footer.done, isEnabled: true)
        case .none:
            return FooterState(title: LocalizedStrings.Footer.continueTitle, isEnabled: true)
        }
    }

    public func progressToFourthScreen(
        snapshotOverallProgress: CGFloat,
        rawProgressForPage3: CGFloat
    ) -> CGFloat {
        snapshotOverallProgress >= CGFloat(lastVisiblePageIndex)
            ? (hasSkillLevelSelected ? 1 : 0)
            : rawProgressForPage3
    }
}
