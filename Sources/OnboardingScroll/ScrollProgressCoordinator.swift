import Foundation

public actor ScrollProgressCoordinator {
    private var continuation: AsyncStream<ScrollProgressSnapshot>.Continuation?

    public init() {}

    public nonisolated func connect(to stream: AsyncStream<ScrollProgressSnapshot>) {
        Task {
            for await snapshot in stream {
                await report(snapshot)
            }
        }
    }

    public func progressStream() -> AsyncStream<ScrollProgressSnapshot> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.clearContinuation() }
            }
        }
    }

    public func report(_ snapshot: ScrollProgressSnapshot) {
        continuation?.yield(snapshot)
    }

    private func clearContinuation() {
        continuation = nil
    }
}
