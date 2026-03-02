import Foundation

public enum LocalizedStrings {

    public enum Welcome {
        public static let footer = String(localized: "Welcome to djay!")
    }

    public enum SkillPicker {
        public static let title = String(localized: "Welcome DJ")
        public static let subtitle = String(localized: "What's your DJ skill level?")
    }

    public enum SkillLevel {
        public static let beginner = String(localized: "I'm new to DJing")
        public static let intermediate = String(localized: "I've used DJ apps before")
        public static let advanced = String(localized: "I'm a professional DJ")
        public static let beginnerCongrats = String(localized: "Start with the basics and build your skills step by step.")
        public static let intermediateCongrats = String(localized: "You're ready to explore more advanced techniques.")
        public static let advancedCongrats = String(localized: "Challenge yourself with complex projects.")
    }

    public enum Congratulations {
        public static let title = String(localized: "Congratulations!")
        public static let defaultSubtitle = String(localized: "Let's get started!")
    }

    public enum Footer {
        public static let continueTitle = String(localized: "Continue")
        public static let letsGo = String(localized: "Let's go")
        public static let done = String(localized: "Done")
    }

    public enum MainContent {
        public static let mixMusic = String(localized: "Mix Your Favorite Music")
        public static let appleDesignAward = String(localized: "Apple Design Award")
        public static let winner = String(localized: "Winner")
    }

    public enum Accolades {
        public static let provenQuality = String(localized: "Proven Quality")
        public static let provenQualitySubtitle = String(localized: "Built with industry best practices and attention to detail.")
        public static let performanceFirst = String(localized: "Performance First")
        public static let performanceFirstSubtitle = String(localized: "Optimized for speed and responsiveness.")
        public static let beautifulDesign = String(localized: "Beautiful Design")
        public static let beautifulDesignSubtitle = String(localized: "Thoughtful UX and cohesive visual language.")
    }

    public enum SettingsMenu {
        public static let figma = String(localized: "Figma")
        public static let experimental = String(localized: "Experimental")
        public static let debug = String(localized: "Debug")
        public static let appearance = String(localized: "Appearance")
        public static let developer = String(localized: "Developer")
    }
}
