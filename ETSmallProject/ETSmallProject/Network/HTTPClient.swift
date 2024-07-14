import Foundation

protocol HTTPClient {
	func request(endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void)
}
