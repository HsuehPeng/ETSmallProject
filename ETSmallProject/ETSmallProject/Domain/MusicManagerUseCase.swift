import AVFoundation
import Foundation

public protocol MusicManagerUseCaseProtocol {
	func start(from url: URL)
	func pause()
	func resume()
	func reset()
}

public final class MusicManager: MusicManagerUseCaseProtocol {
	private var player: AVPlayer?

	public func start(from url: URL) {
		let playerItem = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: playerItem)
		player?.play()
	}
	
	public func pause() {
		player?.pause()
	}
	
	public func resume() {
		player?.play()
	}
	
	public func reset() {
		player = nil
	}
}
