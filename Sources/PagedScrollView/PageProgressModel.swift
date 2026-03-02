import Foundation

public struct PageProgress: Sendable {
    public let pageIndex: Int
    public let progress: CGFloat
    public let isActive: Bool

    public init(pageIndex: Int, progress: CGFloat, isActive: Bool) {
        self.pageIndex = pageIndex
        self.progress = progress
        self.isActive = isActive
    }
}

public struct ScrollProgressSnapshot: Sendable {
    public let overallProgress: CGFloat
    public let pageProgress: [PageProgress]

    public init(overallProgress: CGFloat, pageProgress: [PageProgress]) {
        self.overallProgress = overallProgress
        self.pageProgress = pageProgress
    }

    public func progress(forPage index: Int) -> CGFloat {
        pageProgress.first { $0.pageIndex == index }?.progress ?? 0
    }
}
