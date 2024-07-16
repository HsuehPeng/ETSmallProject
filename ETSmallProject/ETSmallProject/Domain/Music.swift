import Foundation

public struct Music: Equatable {
	public let trackName: String
	public let trackTimeMillis: Int
	public let artworkUrl100: String?
	public let longDescription: String?
	public let previewUrl: String
}
