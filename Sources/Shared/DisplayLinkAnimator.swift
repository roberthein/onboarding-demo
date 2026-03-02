import QuartzCore
import UIKit

final class DisplayLinkAnimator {
    private let startTime: CFTimeInterval
    private let duration: CFTimeInterval
    private var continuation: AsyncStream<CGFloat>.Continuation?
    private var displayLink: CADisplayLink?

    init(startTime: CFTimeInterval, duration: CFTimeInterval) {
        self.startTime = startTime
        self.duration = duration
    }

    func progressStream() -> AsyncStream<CGFloat> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            self.continuation = continuation
            let ref = WeakSendable(self)
            continuation.onTermination = { _ in
                Task { @MainActor in
                    ref.value?.invalidate()
                }
            }
        }
    }

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
        continuation?.finish()
        continuation = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        let rawProgress = min(1, elapsed / duration)
        let easedProgress = rawProgress.easeInOut()
        continuation?.yield(easedProgress)
        if easedProgress >= 1 {
            invalidate()
        }
    }
}
