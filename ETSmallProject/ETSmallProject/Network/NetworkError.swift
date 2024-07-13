import Foundation

enum NetworkError: Error {
	case invalidRequest
	case requestFailed(Error)
	case invalidResponse
	case invalidData
	case decodingError(Error)
}
