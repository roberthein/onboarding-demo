import UIKit

public protocol DebugProviding: Sendable {
    var isDebugEnabled: Bool { get async }
    func setDebugEnabled(_ enabled: Bool) async
    func debugStream() async -> AsyncStream<Bool>
}

public actor DebugProvider: DebugProviding {
    private var _isDebugEnabled: Bool
    private var continuations: [UUID: AsyncStream<Bool>.Continuation] = [:]

    public init(initialDebugEnabled: Bool = false) {
        self._isDebugEnabled = initialDebugEnabled
    }

    public var isDebugEnabled: Bool {
        _isDebugEnabled
    }

    public func setDebugEnabled(_ enabled: Bool) {
        _isDebugEnabled = enabled
        continuations.values.forEach { $0.yield(enabled) }
    }

    public func debugStream() -> AsyncStream<Bool> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.yield(_isDebugEnabled)
            continuations[id] = continuation
            continuation.onTermination = { [weak self, id] _ in
                guard let self else { return }
                Task { await self.removeContinuation(id: id) }
            }
        }
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }
}
