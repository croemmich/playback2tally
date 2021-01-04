import Defaults
import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let playback = Self("playback")
    static let tally = Self("tally")
    static let overlay = Self("tally overlay")
}

enum PlaybackVariant: String, CaseIterable, Codable {
    case mitti = "Mitti"
}

enum UdmProtocol: String, CaseIterable, Codable {
    case tcp = "tcp"
    case udp = "udp"
}

enum OverlayType: String, CaseIterable, Codable {
    case box = "box"
    case border = "border"
}


extension Defaults.Keys {
    static let udmHost = Key<String>("udmHost", default: "")
    static let udmPort = Key<Int>("udmPort", default: 5727)
    static let udmProto = Key<UdmProtocol>("udmProto", default: .tcp)
    static let udmAddressCueName = Key<Int>("udmAddressCueName", default: 0)
    static let udmAddressTimeTotal = Key<Int>("udmAddressTimeTotal", default: 1)
    static let udmAddressTimeLeft = Key<Int>("udmAddressTimeLeft", default: 2)
    static let udmAddressTimeElapsed = Key<Int>("udmAddressTimeElapsed", default: 3)
    static let udmAddressPreviousCueName = Key<Int>("udmAddressPreviousCueName", default: 4)
    static let udmAddressNextCueName = Key<Int>("udmAddressNextCueName", default: 5)
    static let udmAddressSelectedCueName = Key<Int>("udmAddressSelectedCueName", default: 6)
    
    static let udmServerPort = Key<Int>("udmServerPort", default: 9800)
    static let udmServerProto = Key<UdmProtocol>("udmServerProto", default: .udp)
    
    static let tallyOverlayType = Key<OverlayType>("tallyOverlayType", default: .box)
    static let tallyOverlayShowLabel = Key<Bool>("tallyOverlayShowLabel", default: false)
    static let tallyOverlayOpacity = Key<Float>("tallyOverlayOpacity", default: 1.0)
    static let tallyOverlayTallyAddress = Key<Int>("tallyOverlayTallyAddress", default: -1)
    static let tallyOverlayTallyColor1 = Key<String>("tallyOverlayTallyColor1", default: "00ff00")
    static let tallyOverlayTallyColor2 = Key<String>("tallyOverlayTallyColor2", default: "ff0000")
    static let tallyOverlayTallyColorBoth = Key<String>("tallyOverlayTallyColorBoth", default: "ffc000")
    
    static let playbackVariant = Key<PlaybackVariant>("playbackVariant", default: .mitti)

    static let mittiFeedbackPort = Key<Int>("mittiFeedbackPort", default: 1234)
    static let mittiHost = Key<String>("mittiHost", default: "localhost")
    static let mittiPort = Key<Int>("mittiPort", default: 51000)
}
