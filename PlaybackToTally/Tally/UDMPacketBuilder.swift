import Cocoa

class UDMPacketBuilder: NSObject {

    static let displayInvalidCharacterRegex = try! NSRegularExpression(pattern: #"[^\x20-\x7E]"#, options: [])

    var address: UInt8 = 0
    var control: UInt8 = 0
    var display: [UInt8] = Array(repeating: UInt8(0), count: 16)

    @discardableResult
    func address(index: UInt8) -> UDMPacketBuilder {
        if (index <= 126) {
            address = index
        } else {
            address = 126
        }
        return self
    }

    @discardableResult
    func display(text: String) -> UDMPacketBuilder {
        let truncatedText = String(text.prefix(16))
        let sanitizedText = UDMPacketBuilder.displayInvalidCharacterRegex.stringByReplacingMatches(in: truncatedText, range: NSRange(location: 0, length: truncatedText.count), withTemplate: "-")
        var newDisplay = sanitizedText.compactMap(\.asciiValue)
        let padCharacters = 16 - newDisplay.count
        if padCharacters != 0 {
            newDisplay = newDisplay + Array(repeating: UInt8(0), count: padCharacters)
        }
        display = newDisplay
        return self
    }

    @discardableResult
    func tally1() -> UDMPacketBuilder {
        control = control | UDMPacket.tally1
        return self
    }

    @discardableResult
    func tally2() -> UDMPacketBuilder {
        control = control | UDMPacket.tally2
        return self
    }

    @discardableResult
    func tally3() -> UDMPacketBuilder {
        control = control | UDMPacket.tally3
        return self
    }

    @discardableResult
    func tally4() -> UDMPacketBuilder {
        control = control | UDMPacket.tally4
        return self
    }

    @discardableResult
    func brightnessOneHalf() -> UDMPacketBuilder {
        control = control | UDMPacket.brightnessOneHalf
        return self
    }

    @discardableResult
    func brightnessOneSeventh() -> UDMPacketBuilder {
        control = control | UDMPacket.brightnessOneSeventh
        return self
    }

    @discardableResult
    func brightnessFull() -> UDMPacketBuilder {
        return brightnessOneHalf().brightnessOneSeventh()
    }

    func build() -> UDMPacket {
        var payload = Array(repeating: UInt8(0), count: 18)
        payload[0] = address + 0x80
        payload[1] = control
        payload.replaceSubrange(Range(NSMakeRange(2, 16))!, with: display)
        return UDMPacket(bytes: payload)
    }

}
