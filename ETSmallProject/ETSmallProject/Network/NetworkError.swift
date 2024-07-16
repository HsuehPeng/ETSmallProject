import Foundation

public enum NetworkError: Error {
	case invalidRequest
	case requestFailed(Error)
	case invalidResponse
	case invalidData
}
