import Foundation

struct MusicDTO: Decodable {
	let id: String
	let trackName: String
	let trackTimeMillis: Int
	let artworkUrl100: String
	let longDescription: String?
}

extension MusicDTO {
	func mapToDomain() -> Music {
		return Music(
			id: self.id,
			trackName: self.trackName,
			trackTimeMillis: self.trackTimeMillis,
			artworkUrl100: self.artworkUrl100,
			longDescription: self.longDescription
		)
	}
}
