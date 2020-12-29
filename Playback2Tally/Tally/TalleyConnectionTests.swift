import XCTest
import Network

@testable import Playback2Tally

class TalleyConnectionTests: XCTestCase {
    
    func testSend() throws {
        let packet = UDMPacketBuilder().address(index: 0).tally1().brightnessFull().display(text: "Hello World!").build()
        let conn = TalleyConnection(host: "127.0.0.1", port: 40001)
        conn.send(packet: packet)
    }

}
