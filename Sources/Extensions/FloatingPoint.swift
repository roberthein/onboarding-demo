import Foundation

public extension FloatingPoint {

    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }

    func map(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        guard from.lowerBound <= from.upperBound, to.lowerBound <= to.upperBound, from.upperBound - from.lowerBound != 0 else {
            return self
        }
        return ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
    }

    func easeInOut() -> Self {
        let normalizedValue = min(max(self, 0), 1)
        return normalizedValue * normalizedValue * (3 - 2 * normalizedValue)
    }
}
