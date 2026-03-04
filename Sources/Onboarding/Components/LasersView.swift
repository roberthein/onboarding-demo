import SwiftUI
import UIKit
import Combine

@MainActor
final class LasersModel: ObservableObject {
    @Published var visibilityProgress: CGFloat = 0
    @Published var accentRGB: SIMD3<Float> = SIMD3<Float>(0.5, 0.5, 0.5)
    @Published var speedMultiplier: CGFloat = 1.0
}

struct LasersView: View {
    @ObservedObject var model: LasersModel
    @State private var startDate: Date = .now

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 60)) { context in
            GeometryReader { proxy in
                Rectangle()
                    .fill(.white)
                    .colorEffect(
                        ShaderLibrary.Lasers(
                            .float2(Float(proxy.size.width), Float(proxy.size.height)),
                            .float(Float(context.date.timeIntervalSince(startDate))),
                            .float3(model.accentRGB.x, model.accentRGB.y, model.accentRGB.z),
                            .float(Float(model.speedMultiplier))
                        )
                    )
                    .opacity(model.visibilityProgress.clamped(to: 0...1))
                    .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
        .compositingGroup()
    }
}

final class LasersHostingController: UIHostingController<LasersView> {
    public init(model: LasersModel) {
        super.init(rootView: LasersView(model: model))
    }

    @MainActor @preconcurrency dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public final class LasersHostingView: UIView {
    private let model = LasersModel()
    private var hostingController: LasersHostingController?
    private var didPrewarm = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, hostingController == nil {
            installHostingController()
        }
    }

    public func setVisibilityProgress(_ progress: CGFloat) {
        model.visibilityProgress = progress
    }
    
    public func setAccentColor(_ color: UIColor) {
        model.accentRGB = Self.rgbComponents(of: color)
    }
    
    public func setSpeedMultiplier(_ multiplier: CGFloat) {
        model.speedMultiplier = multiplier
    }

    public func prewarm() {
        if hostingController == nil {
            installHostingController()
        }
        guard !didPrewarm else { return }
        didPrewarm = true
        model.visibilityProgress = 0.001
        DispatchQueue.main.async { [weak self] in
            self?.model.visibilityProgress = 0
        }
    }

    private func installHostingController() {
        guard let parentVC = nearestViewController else { return }
        let hosting = LasersHostingController(model: model)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        parentVC.addChild(hosting)
        addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        hosting.didMove(toParent: parentVC)
        hostingController = hosting
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            responder = next
        }
        return nil
    }
    
    private static func rgbComponents(of color: UIColor) -> SIMD3<Float> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let resolved = color.resolvedColor(with: UITraitCollection.current)
        guard resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return SIMD3<Float>(0.5, 0.5, 0.5)
        }
        return SIMD3<Float>(Float(red), Float(green), Float(blue))
    }
}
