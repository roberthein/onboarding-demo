import Foundation

public extension FloatingPoint {

    func easeInOut() -> Self {
        let t = min(max(self, 0), 1)
        return t * t * (3 - 2 * t)
    }
}

public extension BinaryFloatingPoint {

    func easeOutBack() -> Self {
        let t = min(max(Double(self), 0), 1)
        let c1 = 0.7
        let c3 = c1 + 1
        let u = t - 1
        let u2 = u * u
        let u3 = u2 * u
        return Self(1 + c3 * u3 + c1 * u2)
    }
}
