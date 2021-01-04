import Defaults
import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let playback = Self("playback")
    static let tally = Self("tally")
}

enum PlaybackVariant: String, CaseIterable, Codable {
    case mitti = "Mitti"
}

extension Defaults.Keys {
    static let udmHost = Key<String>("udmHost", default: "")
    static let udmPort = Key<Int>("udmPort", default: 5727)
    static let udmProto = Key<String>("udmProto", default: "tcp")
    static let udmAddressCueName = Key<Int>("udmAddressCueName", default: 0)
    static let udmAddressTimeTotal = Key<Int>("udmAddressTimeTotal", default: 1)
    static let udmAddressTimeLeft = Key<Int>("udmAddressTimeLeft", default: 2)
    static let udmAddressTimeElapsed = Key<Int>("udmAddressTimeElapsed", default: 3)
    static let udmAddressPreviousCueName = Key<Int>("udmAddressPreviousCueName", default: 4)
    static let udmAddressNextCueName = Key<Int>("udmAddressNextCueName", default: 5)
    static let udmAddressSelectedCueName = Key<Int>("udmAddressSelectedCueName", default: 6)

    static let playbackVariant = Key<PlaybackVariant>("playbackVariant", default: .mitti)

    static let mittiFeedbackPort = Key<Int>("mittiFeedbackPort", default: 1234)
    static let mittiHost = Key<String>("mittiHost", default: "localhost")
    static let mittiPort = Key<Int>("mittiPort", default: 51000)
}
