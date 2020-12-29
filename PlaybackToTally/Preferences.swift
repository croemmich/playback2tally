import Cocoa
import Preferences
import SwiftyUserDefaults

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let playback = Self("playback")
    static let tally = Self("tally")
}

enum PlaybackVariant: String, CaseIterable, DefaultsSerializable {
    case mitti = "Mitti"
}

extension DefaultsKeys {
    var udmHost: DefaultsKey<String> { .init("udmHost", defaultValue: "") }
    var udmPort: DefaultsKey<Int> { .init("udmPort", defaultValue: 5727)}
    var udmAddressCueName: DefaultsKey<Int> { .init("udmAddressCueName", defaultValue: 0)}
    var udmAddressTimeTotal: DefaultsKey<Int> { .init("udmAddressTimeTotal", defaultValue: 1)}
    var udmAddressTimeLeft: DefaultsKey<Int> { .init("udmAddressTimeLeft", defaultValue: 2)}
    var udmAddressTimeElapsed: DefaultsKey<Int> { .init("udmAddressTimeElapsed", defaultValue: 3)}
    var udmAddressPreviousCueName: DefaultsKey<Int> { .init("udmAddressPreviousCueName", defaultValue: 4)}
    var udmAddressNextCueName: DefaultsKey<Int> { .init("udmAddressNextCueName", defaultValue: 5)}

    var playbackVariant: DefaultsKey<PlaybackVariant> { .init("playbackVariant", defaultValue: .mitti)}

    var mittiFeedbackPort: DefaultsKey<Int> { .init("mittiFeedbackPort", defaultValue: 1234)}
    var mittiHost: DefaultsKey<String> { .init("mittiHost", defaultValue: "localhost")}
    var mittiPort: DefaultsKey<Int> { .init("mittiPort", defaultValue: 51000) }
}
