import Foundation

final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession = .init(configuration: .default)) {
		self.session = session
	}
	
	private struct UnexpectedValuesRepresentation: Error {}
	
	private struct URLSessionTaskWrapper: HTTPClientTask {
		let wrapped: URLSessionTask
		
		func cancel() {
			wrapped.cancel()
		}
	}

	func request(endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) -> HTTPClientTask? {
		guard let urlRequest = endpoint.makeRequest() else {
			completion(.failure(.invalidRequest))
			return nil
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
		return URLSessionTaskWrapper(wrapped: task)
	}
}
