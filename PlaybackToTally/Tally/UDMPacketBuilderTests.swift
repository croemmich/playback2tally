import XCTest

@testable import PlaybackToTally

class UDMPacketBuilderTests: XCTestCase {

    func testBuildEmpty() throws {
        let packet = UDMPacketBuilder().build()
        let bytes = packet.getBytes()
        XCTAssertEqual(bytes[0], 0x80)
        XCTAssertEqual(bytes[1], 0)
        XCTAssertEqual(18, bytes.count)
    }

    func testAddressWhenZero() throws {
        let packet = UDMPacketBuilder().address(index: 0).build()
        XCTAssertEqual(0, packet.getAddress())
    }

    func testAddressWhenOne() throws {
        let packet = UDMPacketBuilder().address(index: 1).build()
        XCTAssertEqual(1, packet.getAddress())
    }

    func testAddressWhenOverflows() throws {
        let packet = UDMPacketBuilder().address(index: 200).build()
        XCTAssertEqual(126, packet.getAddress())
    }

    func testDisplayIsEmpty() throws {
        let packet = UDMPacketBuilder().display(text: "").build()
        XCTAssertEqual("", packet.getDisplay())
        XCTAssertEqual(18, packet.getBytes().count)
    }

    func testDisplayIsNotEmpty() throws {
        let display = "Hello World!"
        let packet = UDMPacketBuilder().display(text: display).build()
        XCTAssertEqual(display, packet.getDisplay())
        XCTAssertEqual(18, packet.getBytes().count)
    }
    
    func testTally1() throws {
        let packet = UDMPacketBuilder().tally1().build()
        XCTAssertTrue(packet.isTally1())
    }

    func testTally2() throws {
        let packet = UDMPacketBuilder().tally2().build()
        XCTAssertTrue(packet.isTally2())
    }

    func testTally3() throws {
        let packet = UDMPacketBuilder().tally3().build()
        XCTAssertTrue(packet.isTally3())
    }

    func testTally4() throws {
        let packet = UDMPacketBuilder().tally4().build()
        XCTAssertTrue(packet.isTally4())
    }

    func testBrightnessOneSeventh() throws {
        let packet = UDMPacketBuilder().brightnessOneSeventh().build()
        XCTAssertTrue(packet.isBrightnessOneSeventh())
    }

    func testBrightnessOneHalf() throws {
        let packet = UDMPacketBuilder().brightnessOneHalf().build()
        XCTAssertTrue(packet.isBrightnessOneHalf())
    }

    func testBrightnessFull() throws {
        let packet = UDMPacketBuilder().brightnessFull().build()
        XCTAssertTrue(packet.isBrightnessFull())
    }

    func testCommonPackets() throws {
        let display = "Hello World!"
        var packet = UDMPacketBuilder().address(index: 0).brightnessFull().display(text: display).build()
        XCTAssertEqual(0, packet.getAddress())
        XCTAssertTrue(packet.isBrightnessFull())
        XCTAssertFalse(packet.isTally1())
        XCTAssertEqual(display, packet.getDisplay())

        packet = UDMPacketBuilder().address(index: 1).brightnessFull().display(text: display).build()
        XCTAssertEqual(1, packet.getAddress())
        XCTAssertTrue(packet.isBrightnessFull())
        XCTAssertFalse(packet.isTally1())
        XCTAssertEqual(display, packet.getDisplay())

        packet = UDMPacketBuilder().address(index: 1).display(text: display).build()
        XCTAssertEqual(1, packet.getAddress())
        XCTAssertFalse(packet.isBrightnessOneHalf())
        XCTAssertFalse(packet.isBrightnessOneSeventh())
        XCTAssertFalse(packet.isTally1())
        XCTAssertEqual(display, packet.getDisplay())

        packet = UDMPacketBuilder().address(index: 0).brightnessFull().display(text: display).tally1().build()
        XCTAssertEqual(0, packet.getAddress())
        XCTAssertTrue(packet.isBrightnessFull())
        XCTAssertTrue(packet.isTally1())
        XCTAssertFalse(packet.isTally2())
        XCTAssertEqual(display, packet.getDisplay())

        packet = UDMPacketBuilder().build()
        XCTAssertEqual(0, packet.getAddress())
        XCTAssertFalse(packet.isBrightnessFull())
        XCTAssertFalse(packet.isTally1())
        XCTAssertFalse(packet.isTally2())
        XCTAssertEqual("", packet.getDisplay())
    }

}
