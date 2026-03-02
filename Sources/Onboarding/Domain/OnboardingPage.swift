import Foundation

public enum OnboardingPage: Int, CaseIterable, Sendable {
    case accolades = 0
    case skillPicker = 1
    case congratulations = 2
    case done = 3

    public static let totalPageCount = 4
}
