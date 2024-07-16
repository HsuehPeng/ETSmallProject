import AVFoundation
import ETSmallProject
import XCTest

class MusicManagerTests: XCTestCase {
	func test_init_currentItemIsNil() {
		let (sut, player) = makeSUT()
		
		XCTAssertNil(player.currentItem)
	}
	
	func test_start_currentItemIsNotNil() {
		let (sut, player) = makeSUT()
		let url = URL(string: "https://test.com")!
		
		sut.start(from: url)
		
		XCTAssertNotNil(player.currentItem)
	}
	
	private func makeSUT() -> (sut: MusicManager, view: MockAVPlayer) {
		let player = MockAVPlayer()
		let sut = MusicManager(player: player)
		return (sut, player)
	}
	
	private class MockAVPlayer: AVPlayer {
		private(set) var isPlaying = false
		private(set) var didPause = false

		override func play() {
			isPlaying = true
		}

		override func pause() {
			didPause = true
			isPlaying = false
		}
	}
}
