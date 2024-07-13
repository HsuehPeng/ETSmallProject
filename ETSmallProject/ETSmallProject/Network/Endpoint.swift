import Foundation

protocol Endpoint {
	var baseURL: URL { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var queryItems: [URLQueryItem]? { get }
	var headers: [String: String]? { get }
	var body: Data? { get }
	
	func makeRequest() -> URLRequest?
}

extension Endpoint {
	func makeRequest() -> URLRequest? {
		var components = URLComponents()
		components.scheme = baseURL.scheme
		components.host = baseURL.host
		components.path = baseURL.path
		components.queryItems = queryItems
		
		guard let url = components.url else {
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.allHTTPHeaderFields = headers
		request.httpBody = body
		return request
	}
}
