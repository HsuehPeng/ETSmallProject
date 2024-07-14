import AVFoundation
import Foundation

protocol MusicManagerUseCaseProtocol {
	func start(from url: URL)
	func pause()
	func resume()
}

final class MusicManager: MusicManagerUseCaseProtocol {
	private var player: AVPlayer?

	func start(from url: URL) {
		let playerItem = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: playerItem)
		player?.play()
	}
	
	func pause() {
		player?.pause()
	}
	
	func resume() {
		player?.play()
	}
}
