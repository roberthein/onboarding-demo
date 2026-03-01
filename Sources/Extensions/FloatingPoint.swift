import Foundation

public extension FloatingPoint {

    func map(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        guard from.lowerBound <= from.upperBound, to.lowerBound <= to.upperBound, from.upperBound - from.lowerBound != 0 else {
            return self
        }
        return ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
    }
}
