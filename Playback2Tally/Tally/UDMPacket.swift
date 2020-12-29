import Cocoa

class UDMPacket: NSObject {

    static let tally1 = UInt8(1)
    static let tally2 = UInt8(2)
    static let tally3 = UInt8(4)
    static let tally4 = UInt8(8)
    static let brightnessOneHalf = UInt8(16)
    static let brightnessOneSeventh = UInt8(32)

    let bytes: [UInt8]

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    func getBytes() -> [UInt8] {
        return bytes
    }

    func getAddress() -> UInt8 {
        return bytes[0] - 0x80
    }

    func isTally1() -> Bool {
        bytes[1] & UDMPacket.tally1 == UDMPacket.tally1
    }

    func isTally2() -> Bool {
        bytes[1] & UDMPacket.tally2 == UDMPacket.tally2
    }

    func isTally3() -> Bool {
        bytes[1] & UDMPacket.tally3 == UDMPacket.tally3
    }

    func isTally4() -> Bool {
        bytes[1] & UDMPacket.tally4 == UDMPacket.tally4
    }

    func isBrightnessOneHalf() -> Bool {
        bytes[1] & UDMPacket.brightnessOneHalf == UDMPacket.brightnessOneHalf
    }

    func isBrightnessOneSeventh() -> Bool {
        bytes[1] & UDMPacket.brightnessOneSeventh == UDMPacket.brightnessOneSeventh
    }

    func isBrightnessFull() -> Bool {
        return isBrightnessOneHalf() && isBrightnessOneSeventh()
    }

    func getDisplay() -> String {
        String(bytes: bytes.suffix(from: 2), encoding: .ascii)!.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
    }

}
