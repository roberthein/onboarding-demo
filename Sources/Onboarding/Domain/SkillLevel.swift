import Foundation
import CoreGraphics

public enum SkillLevel: String, CaseIterable, Sendable {

    public struct HeadBobParams {
        public let freq1: Double
        public let freq2: Double
        public let freq3: Double
        public let phase2: Double
        public let phase3: Double
        public let bobAmp1: CGFloat
        public let bobAmp2: CGFloat
        public let bobAmp3: CGFloat
        public let tiltFreq1: Double
        public let tiltFreq2: Double
        public let tiltAmp: CGFloat
        public let swayFreq: Double
        public let swayAmp: CGFloat

        public static func `for`(_ level: SkillLevel?) -> HeadBobParams {
            switch level {
            case .beginner: return HeadBobParams(freq1: 2.8, freq2: 3.6, freq3: 2.0, phase2: 1.2, phase3: 0.8, bobAmp1: 6.0, bobAmp2: 3.5, bobAmp3: 2.0, tiltFreq1: 2.2, tiltFreq2: 2.9, tiltAmp: 0.038, swayFreq: 2.5, swayAmp: 3.5)
            case .intermediate: return HeadBobParams(freq1: 4.2, freq2: 5.4, freq3: 3.6, phase2: 1.2, phase3: 0.8, bobAmp1: 12.0, bobAmp2: 6.5, bobAmp3: 3.5, tiltFreq1: 3.5, tiltFreq2: 4.5, tiltAmp: 0.065, swayFreq: 4.2, swayAmp: 7.5)
            case .advanced: return HeadBobParams(freq1: 6.8, freq2: 8.2, freq3: 5.8, phase2: 1.2, phase3: 0.8, bobAmp1: 7.0, bobAmp2: 4.0, bobAmp3: 2.2, tiltFreq1: 4.5, tiltFreq2: 5.5, tiltAmp: 0.082, swayFreq: 5.2, swayAmp: 10.0)
            case nil: return .for(.intermediate)
            }
        }
    }

    public static func decibelSimulationParams(for level: SkillLevel?) -> (baseLevel: CGFloat, chaos: CGFloat, tempoMultiplier: CGFloat, spikeBurstWeight: CGFloat) {
        switch level ?? .intermediate {
        case .beginner: return (0.28, 0.3, 0.65, 0.2)
        case .intermediate: return (0.48, 0.48, 1.0, 0.38)
        case .advanced: return (0.62, 0.62, 1.5, 0.72)
        }
    }

    public static func simulatedDecibelLevel(
        at time: Date,
        baseLevel: CGFloat,
        chaos: CGFloat,
        tempoMultiplier: CGFloat,
        spikeBurstWeight: CGFloat
    ) -> CGFloat {
        let t = time.timeIntervalSince1970 * Double(tempoMultiplier)
        let w1 = sin(t * 3.7) * 0.5 + 0.5
        let w2 = sin(t * 7.3 + 1.2) * 0.5 + 0.5
        let w3 = sin(t * 11.9 - 2.7) * 0.5 + 0.5
        let w4 = sin(t * 19.1 + 4.1) * 0.5 + 0.5
        let w5 = sin(t * 23.7 - 0.8) * 0.5 + 0.5
        let w6 = sin(t * 31.3 + 3.3) * 0.5 + 0.5
        let w7 = sin(t * 0.97 * t + 5.1) * 0.5 + 0.5
        let w8 = sin(t * 41.1 - t * 0.3) * 0.5 + 0.5
        let spike = abs(sin(t * 13.7) * sin(t * 17.3)) * Double(spikeBurstWeight)
        let burst = max(0, sin(t * 2.1) + 0.6) * (sin(t * 29.1) * 0.5 + 0.5) * Double(spikeBurstWeight)
        let raw = (w1 + w2 * 0.9 + w3 * 0.7 + w4 * 0.6 + w5 * 0.5 + w6 * 0.4 + w7 * 0.3 + w8 * 0.2) / 4.2
            + spike + burst
        return min(1, max(0, baseLevel + CGFloat(raw - 0.5) * chaos))
    }

    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    public var displayName: String {
        switch self {
        case .beginner: return LocalizedStrings.SkillLevel.beginner
        case .intermediate: return LocalizedStrings.SkillLevel.intermediate
        case .advanced: return LocalizedStrings.SkillLevel.advanced
        }
    }

    public var congratulationSubtitle: String {
        switch self {
        case .beginner: return LocalizedStrings.SkillLevel.beginnerCongrats
        case .intermediate: return LocalizedStrings.SkillLevel.intermediateCongrats
        case .advanced: return LocalizedStrings.SkillLevel.advancedCongrats
        }
    }

    public var faceImageName: String {
        switch self {
        case .beginner: return "dj-face-beginner"
        case .intermediate: return "dj-face-intermediate"
        case .advanced: return "dj-face-pro"
        }
    }

}
