import AVFoundation
import Foundation

public protocol MusicManagerUseCaseProtocol {
	func start(from url: URL)
	func pause()
	func resume()
	func reset()
}

public final class MusicManager: MusicManagerUseCaseProtocol {
	private let player: AVPlayer

	public func start(from url: URL) {
		let playerItem = AVPlayerItem(url: url)
		player.replaceCurrentItem(with: playerItem)
		player.play()
	}
	
	public func pause() {
		player.pause()
	}
	
	public func resume() {
		player.play()
	}
	
	public func reset() {
		player.replaceCurrentItem(with: nil)
	}
	
	public init(player: AVPlayer = .init(playerItem: nil)) {
		self.player = player
	}
}
