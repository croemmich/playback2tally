import XCTest

@testable import PlaybackToTally

class UDMPacketTests: XCTestCase {

    func testGetAddress() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        bytes[0] = 0x80 + 0
        var packet = UDMPacket(bytes: bytes)
        XCTAssertEqual(0, packet.getAddress())

        bytes[0] = 0x80 + 10
        packet = UDMPacket(bytes: bytes)
        XCTAssertEqual(10, packet.getAddress())
    }

    func testIsTally1() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isTally1())


        bytes[1] = 1 | 2
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isTally1())
    }

    func testIsTally2() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isTally2())


        bytes[1] = 2 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isTally2())
    }

    func testIsTally3() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isTally3())


        bytes[1] = 4 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isTally3())
    }

    func testIsTally4() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isTally4())


        bytes[1] = 8 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isTally4())
    }

    func testIsBrightnessOneHalf() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isBrightnessOneHalf())

        bytes[1] = 16 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isBrightnessOneHalf())
    }

    func testIsBrightnessOneSeventh() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isBrightnessOneSeventh())

        bytes[1] = 32 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isBrightnessOneSeventh())
    }

    func testIsBrightnessFull() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertFalse(packet.isBrightnessFull())

        bytes[1] = 48 | 1
        packet = UDMPacket(bytes: bytes)
        XCTAssertTrue(packet.isBrightnessFull())
    }

    func testGetDisplay() throws {
        var bytes = Array(repeating: UInt8(0), count: 18)
        var packet = UDMPacket(bytes: bytes)
        XCTAssertEqual("", packet.getDisplay())

        let display = "Hello World!"
        bytes.replaceSubrange(Range(NSMakeRange(2, display.count))!, with: display.compactMap(\.asciiValue))
        packet = UDMPacket(bytes: bytes)
        XCTAssertEqual(display, packet.getDisplay())
    }

}
