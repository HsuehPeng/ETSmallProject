import Foundation

protocol HTTPClientTask {
	func cancel()
}

protocol HTTPClient {
	@discardableResult
	func request(endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void)  -> HTTPClientTask?
}
