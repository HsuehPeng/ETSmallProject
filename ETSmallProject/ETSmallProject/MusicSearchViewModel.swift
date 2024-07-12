import Foundation
import RxCocoa
import RxSwift

final class MusicSearchViewModel {
	private let disposebag = DisposeBag()

	func transform(input: Input) -> Output {
		let searchMusicObservable = Observable.merge([
			input.searchTermDriver.debounce(.milliseconds(300)).asObservable(),
			input.searchButtonTapSignal.withLatestFrom(input.searchTermDriver).asObservable()
		])
				
		searchMusicObservable.subscribe(onNext: { term in
			print(term)
		}).disposed(by: disposebag)
		return .init()
	}
}

extension MusicSearchViewModel {
	struct Input {
		let searchTermDriver: Driver<String>
		let searchButtonTapSignal: Signal<Void>
	}
	
	struct Output {
		
	}
	
	struct Constants {
		static let searchMusicTitle = "Search Music"
		static let searchPlaceHolder = "Enter keyword here"
		static let searchButtonTitle = "Search"
		static let playingTitle = "正在播放"
		static let play = "▶️"
		static let pause = "⏸️"
	}
}
