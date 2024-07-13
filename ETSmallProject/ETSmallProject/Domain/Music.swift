import Foundation

struct Music: Identifiable {
	let id: String
	let trackName: String
	let trackTimeMillis: Int
	let artworkUrl100: String
	let longDescription: String?
}
