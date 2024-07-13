import Foundation

protocol Endpoint {
	var baseURL: URL { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var headers: [String: String]? { get }
	var body: Data? { get }
	
	func makeRequest() -> URLRequest?
}

extension Endpoint {
	func makeRequest() -> URLRequest? {
		guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
			return nil
		}
		components.path = path
		
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
