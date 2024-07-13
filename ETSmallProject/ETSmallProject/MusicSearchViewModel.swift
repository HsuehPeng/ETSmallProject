import Foundation
import Differentiator
import RxCocoa
import RxSwift

final class MusicSearchViewModel {
	private let disposebag = DisposeBag()

	func transform(input: Input) -> Output {
		let searchMusicObservable = Observable.merge([
			input.searchTermDriver.debounce(.milliseconds(300)).asObservable(),
			input.searchButtonTapSignal.withLatestFrom(input.searchTermDriver).asObservable()
		])
		
		let musicSectionDriver = searchMusicObservable.flatMapLatest { term -> Observable<[SectionModel]> in
			let musicCellViewModel: [MusicCollectionViewCellViewModel] = [
				.init(trackName: "Track name1", trackTime: "4:15", imageUrlString: "", longDescription: "longDescription"),
				.init(trackName: "Track name2", trackTime: "4:15", imageUrlString: "", longDescription: "longDescription"),
				.init(trackName: "Track name3", trackTime: "4:15", imageUrlString: "", longDescription: "longDescription")
			]
			
			let items = musicCellViewModel.map { Item.music($0) }
			let section = SectionModel(items: items)
			return Observable.just([section]).delay(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
		}.asDriver(onErrorJustReturn: [])
		
		let loadingSectionDriver = searchMusicObservable.flatMapLatest { _ -> Observable<[SectionModel]> in
			let items = [Item.loading]
			return .just([SectionModel(items: items)])
		}.asDriver(onErrorJustReturn: [])
		
		let dataSourceDriver: Driver<[SectionModel]> = Driver.merge(
			musicSectionDriver,
			loadingSectionDriver
		)
		
		return Output(dataSourceDriver: dataSourceDriver)
	}
}

extension MusicSearchViewModel {
	struct Input {
		let searchTermDriver: Driver<String>
		let searchButtonTapSignal: Signal<Void>
	}
	
	struct Output {
		let dataSourceDriver: Driver<[SectionModel]>
	}
	
	struct Constants {
		static let searchMusicTitle = "Search Music"
		static let searchPlaceHolder = "Enter keyword here"
		static let searchButtonTitle = "Search"
		static let playingTitle = "正在播放"
		static let play = "▶️"
		static let pause = "⏸️"
	}
	
	enum Item {
		case music(MusicCollectionViewCellViewModel)
		case loading
	}
	
	struct SectionModel: SectionModelType {
		var items: [Item]

		init(original: SectionModel, items: [Item]) {
			self = original
			self.items = items
		}
		
		init(items: [Item]) {
			self.items = items
		}
	}
}
