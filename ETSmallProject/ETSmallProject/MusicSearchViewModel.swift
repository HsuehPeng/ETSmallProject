import Foundation

final class MusicSearchViewModel {
	struct Input {
		
	}
	
	struct Output {
		
	}
	
	func transform(input: Input) -> Output {
		return .init()
	}
}

extension MusicSearchViewModel {
	struct Constants {
		static let searchMusicTitle = "Search Music"
		static let searchPlaceHolder = "Enter keyword here"
		static let searchButtonTitle = "Search"
		static let playingTitle = "正在播放"
		static let play = "▶️"
		static let pause = "⏸️"
	}
}
