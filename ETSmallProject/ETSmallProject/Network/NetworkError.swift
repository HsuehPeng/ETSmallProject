import Foundation

public enum NetworkError: Error, Equatable {
	case invalidRequest
	case requestFailed(Error)
	case invalidResponse
	case invalidData
	
	public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidRequest, .invalidRequest),
			(.invalidResponse, .invalidResponse),
			(.invalidData, .invalidData),
			(.requestFailed, .requestFailed):
			return true
		default:
			return false
		}
	}
}
