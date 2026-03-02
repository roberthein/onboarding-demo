import Foundation

public extension BinaryFloatingPoint {

    func easeOutBack() -> Self {
        let normalizedValue = min(max(Double(self), 0), 1)
        let overshootCoefficient = 0.7
        let cubicCoefficient = overshootCoefficient + 1
        let offsetFromOne = normalizedValue - 1
        let offsetSquared = offsetFromOne * offsetFromOne
        let offsetCubed = offsetSquared * offsetFromOne
        return Self(1 + cubicCoefficient * offsetCubed + overshootCoefficient * offsetSquared)
    }
}
