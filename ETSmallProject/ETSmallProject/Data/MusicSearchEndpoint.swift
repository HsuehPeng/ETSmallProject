import Foundation

struct MusicSearchEndpoint: Endpoint {
	let baseURL: URL = URL(string: "https://itunes.apple.com")!
	let path: String = "/search"
	let method: HTTPMethod = .get
	var queryItems: [URLQueryItem]?
	var headers: [String : String]? = nil
	var body: Data? = nil
	
	init(searchTerm: String) {
		self.queryItems = [
			.init(name: "term", value: searchTerm)
		]
	}
}
