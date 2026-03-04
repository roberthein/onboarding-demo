import SwiftUI
import UIKit

struct GradientView: View {
    let progress: CGFloat
    let primaryColor: UIColor
    let secondaryColor: UIColor

    init(
        progress: CGFloat,
        primaryColor: UIColor,
        secondaryColor: UIColor
    ) {
        self.progress = progress
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    private var primary: Color { Color(uiColor: primaryColor) }
    private var secondary: Color { Color(uiColor: secondaryColor) }

    var body: some View {
        gradient
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var gradient: LinearGradient {
        let (startPoint, endPoint, startColor, endColor) = interpolatedValues
        return LinearGradient(
            colors: [startColor, endColor],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    private var interpolatedValues: (UnitPoint, UnitPoint, Color, Color) {
        if progress < 0 {
            let easedProgress = (progress + 1).easeInOut()
            let start = UnitPoint(x: 0.5 + 0.5 * easedProgress, y: 0.5 * (1 - easedProgress))
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(secondaryColor, primaryColor, blend: easedProgress))
            return (start, end, secondary, endColor)
        } else if progress <= 2 {
            return (
                UnitPoint(x: 1, y: 0),
                UnitPoint(x: 0.5, y: 1),
                secondary,
                primary
            )
        } else {
            let easedProgress = min(1, progress - 2).easeInOut()
            let start = UnitPoint(x: 1 - 0.5 * easedProgress, y: 0.5 * easedProgress)
            let end = UnitPoint(x: 0.5, y: 1)
            let endColor = Color(uiColor: blendColor(primaryColor, secondaryColor, blend: easedProgress))
            return (start, end, secondary, endColor)
        }
    }

    private func blendColor(_ first: UIColor, _ second: UIColor, blend: CGFloat) -> UIColor {
        let blendFactor = min(max(blend, 0), 1)
        var redFirst: CGFloat = 0, greenFirst: CGFloat = 0, blueFirst: CGFloat = 0, alphaFirst: CGFloat = 0
        var redSecond: CGFloat = 0, greenSecond: CGFloat = 0, blueSecond: CGFloat = 0, alphaSecond: CGFloat = 0
        first.getRed(&redFirst, green: &greenFirst, blue: &blueFirst, alpha: &alphaFirst)
        second.getRed(&redSecond, green: &greenSecond, blue: &blueSecond, alpha: &alphaSecond)
        return UIColor(
            red: (1 - blendFactor) * redFirst + blendFactor * redSecond,
            green: (1 - blendFactor) * greenFirst + blendFactor * greenSecond,
            blue: (1 - blendFactor) * blueFirst + blendFactor * blueSecond,
            alpha: (1 - blendFactor) * alphaFirst + blendFactor * alphaSecond
        )
    }
}

struct DecibelOverlayView: View {
    let visible: Bool
    let progress: CGFloat
    let skillLevel: SkillLevel?
    let color: UIColor

    private var overlayColor: Color { Color(uiColor: color) }

    var body: some View {
        Group {
            if visible {
                TimelineView(.animation(minimumInterval: 1 / 60)) { context in
                    let params = SkillLevel.decibelSimulationParams(for: skillLevel)
                    let level = SkillLevel.simulatedDecibelLevel(
                        at: context.date,
                        baseLevel: params.baseLevel,
                        chaos: params.chaos,
                        tempoMultiplier: params.tempoMultiplier,
                        spikeBurstWeight: params.spikeBurstWeight
                    )
                    let t = context.date.timeIntervalSince1970 * Double(params.tempoMultiplier)
                    let sway = 0.25 + CGFloat(level) * 0.5
                    let swayX = (sin(t * 2.4) * 0.2 + sin(t * 3.7 + 1.2) * 0.1) * sway
                    let swayY = sin(t * 1.9 - 0.5) * 0.15 * sway

                    LinearGradient(
                        colors: [
                            overlayColor.opacity(0),
                            overlayColor,
                        ],
                        startPoint: UnitPoint(x: 0.5 + swayX, y: max(0, swayY)),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                    .opacity((0.25 + Double(level) * 0.5) * Double(progress))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

public final class DecibelOverlayBackgroundView: UIView {
    private var hostingController: UIHostingController<DecibelOverlayView>?
    private var visible: Bool = false
    private var progress: CGFloat = 0
    private var skillLevel: SkillLevel?
    private var color: UIColor = .white

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

    public func setOverlay(visible: Bool, skillLevel: SkillLevel?, progress: CGFloat) {
        self.visible = visible
        self.skillLevel = skillLevel
        self.progress = progress
        updateHostedView()
    }

    public func setColor(_ color: UIColor) {
        self.color = color
        updateHostedView()
    }

    private func installHostingController() {
        guard let parentVC = nearestViewController else { return }
        let hosting = UIHostingController(rootView: makeRootView())
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

    private func updateHostedView() {
        guard let hosting = hostingController else { return }
        hosting.rootView = makeRootView()
    }

    private func makeRootView() -> DecibelOverlayView {
        DecibelOverlayView(visible: visible, progress: progress, skillLevel: skillLevel, color: color)
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController { return viewController }
            responder = next
        }
        return nil
    }
}
