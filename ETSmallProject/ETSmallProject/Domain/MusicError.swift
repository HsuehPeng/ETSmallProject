import Foundation

enum MusicError: Error {
	case search
	case unknown
	
	var errorModel: ErrorModel {
		switch self {
		case .search:
			return ErrorModel(title: "Search fail", description: "Fail to get the music result")
		case .unknown:
			return ErrorModel(title: "Unknown Error", description: "Unknown Error")
		}
	}
}
