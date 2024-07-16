import Foundation

struct MusicDTORoot: Decodable {
	struct MusicDTO: Decodable {
		let trackId: Int?
		let trackName: String?
		let trackTimeMillis: Int?
		let artworkUrl100: String?
		let longDescription: String?
		let previewUrl: String?
	}
	
	let results: [MusicDTO]
}

extension MusicDTORoot {
	func mapToDomainMusics() -> [Music] {
		return results.map {
			Music(
				trackName: $0.trackName ?? "Unknown",
				trackTimeMillis: $0.trackTimeMillis ?? 0,
				artworkUrl100: $0.artworkUrl100,
				longDescription: $0.longDescription,
				previewUrl: $0.previewUrl ?? ""
			)
		}
	}
}
