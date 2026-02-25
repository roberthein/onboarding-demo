import Foundation

extension Array {

    /// Safe subscript. Returns `nil` if the index is out of bounds instead of crashing.
    /// - Parameter index: The index to access.
    /// - Returns: The element at `index`, or `nil` if out of bounds.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
