import UIKit

public protocol ThemeProviding: Sendable {
    var currentTheme: Theme { get async }
    func setTheme(_ theme: Theme) async
    func themeStream() async -> AsyncStream<Theme>
}

public actor ThemeProvider: ThemeProviding {
    private var theme: Theme
    private var continuations: [UUID: AsyncStream<Theme>.Continuation] = [:]

    public init(initialTheme: Theme) {
        self.theme = initialTheme
    }

    public var currentTheme: Theme {
        theme
    }

    public func setTheme(_ theme: Theme) {
        self.theme = theme
        continuations.values.forEach { $0.yield(theme) }
    }

    public func themeStream() -> AsyncStream<Theme> {
        let id = UUID()
        return AsyncStream { continuation in
            continuation.yield(theme)
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
