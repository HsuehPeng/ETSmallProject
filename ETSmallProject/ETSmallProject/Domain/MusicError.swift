import Foundation

enum MusicError: Error {
	case search
	case unknown
	case invalidData
	
	var errorModel: ErrorModel {
		switch self {
		case .search:
			return ErrorModel(title: "Search fail", description: "Fail to get the music result")
		case .unknown:
			return ErrorModel(title: "Unknown Error", description: "Unknown Error")
		case .invalidData:
			return ErrorModel(title: "Invalid data", description: "Invalid data")
		}
	}
}
