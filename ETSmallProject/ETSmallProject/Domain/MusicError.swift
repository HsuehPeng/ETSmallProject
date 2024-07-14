import Foundation

enum MusicError: Error {
	case network(NetworkError)
	case unknown
	case invalidData
	
	var errorModel: ErrorModel {
		switch self {
		case let .network(networkError):
			return ErrorModel(title: "Search fail", description: networkError.localizedDescription)
		case .unknown:
			return ErrorModel(title: "Unknown Error", description: "Unknown Error")
		case .invalidData:
			return ErrorModel(title: "Invalid data", description: "Failed to decode data")
		}
	}
}
