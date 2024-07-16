import Foundation

public final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession = .init(configuration: .default)) {
		self.session = session
	}

	public func request(endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
		guard let urlRequest = endpoint.makeRequest() else {
			completion(.failure(.invalidRequest))
			return
		}
		
		let task = session.dataTask(with: urlRequest) { data, response, error in
			if let error = error {
				completion(.failure(.requestFailed(error)))
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
				completion(.failure(.invalidResponse))
				return
			}
			
			guard let data = data else {
				completion(.failure(.invalidData))
				return
			}
			
			completion(.success(data))
		}
			
		task.resume()
	}
}
