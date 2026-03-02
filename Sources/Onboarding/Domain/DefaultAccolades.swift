import Foundation

public enum DefaultAccolades {

    public static let accolades: [Accolade] = [
        Accolade(icon: .trophy, title: LocalizedStrings.Accolades.provenQuality, subtitle: LocalizedStrings.Accolades.provenQualitySubtitle),
        Accolade(icon: .bolt, title: LocalizedStrings.Accolades.performanceFirst, subtitle: LocalizedStrings.Accolades.performanceFirstSubtitle),
        Accolade(icon: .palette, title: LocalizedStrings.Accolades.beautifulDesign, subtitle: LocalizedStrings.Accolades.beautifulDesignSubtitle),
    ]
}
