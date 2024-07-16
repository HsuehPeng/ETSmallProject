import Foundation

public struct Music: Equatable {
	public let trackName: String
	public let trackTimeMillis: Int
	public let artworkUrl100: String?
	public let longDescription: String?
	public let previewUrl: String
	
	public init(
		trackName: String,
		trackTimeMillis: Int,
		artworkUrl100: String?,
		longDescription: String?,
		previewUrl: String
	) {
		self.trackName = trackName
		self.trackTimeMillis = trackTimeMillis
		self.artworkUrl100 = artworkUrl100
		self.longDescription = longDescription
		self.previewUrl = previewUrl
	}
}
