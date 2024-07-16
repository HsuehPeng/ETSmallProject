import AVFoundation
import ETSmallProject
import XCTest

final class MusicManagerTests: XCTestCase {
	func test_init_currentItemIsNil() {
		let (_, player) = makeSUT()
		
		XCTAssertNil(player.currentItem)
	}
	
	func test_start_currentItemIsNotNil() {
		let (sut, player) = makeSUT()
		
		sut.start(from: makeTestUrl())
		
		XCTAssertNotNil(player.currentItem)
	}
	
	func test_start_playerIsPlaying() {
		let (sut, player) = makeSUT()
		
		sut.start(from: makeTestUrl())
		
		XCTAssertTrue(player.isPlaying)
	}
	
	func test_pause_playerIsNotPlaying() {
		let (sut, player) = makeSUT()
		
		sut.start(from: makeTestUrl())
		sut.pause()
		
		XCTAssertFalse(player.isPlaying)
	}
	
	func test_resume_playerIsPlaying() {
		let (sut, player) = makeSUT()
		
		sut.start(from: makeTestUrl())
		sut.pause()
		sut.resume()
		
		XCTAssertTrue(player.isPlaying)
	}
	
	func test_reset_currentItemIsNil() {
		let (sut, player) = makeSUT()
		
		sut.start(from: makeTestUrl())
		sut.reset()
		
		XCTAssertNil(player.currentItem)
	}
	
	private func makeSUT() -> (sut: MusicManager, view: MockAVPlayer) {
		let player = MockAVPlayer()
		let sut = MusicManager(player: player)
		return (sut, player)
	}
	
	private func makeTestUrl() -> URL {
		.init(string: "https://test.com")!
	}
	
	private class MockAVPlayer: AVPlayer {
		private(set) var isPlaying = false

		override func play() {
			isPlaying = true
		}

		override func pause() {
			isPlaying = false
		}
	}
}
