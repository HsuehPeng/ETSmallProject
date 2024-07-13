import Foundation
import Differentiator
import RxCocoa
import RxSwift

final class MusicSearchViewModel {
	private let fetchMusicUseCase: FetchMusicUseCaseProtocol
	private let disposebag = DisposeBag()
	
	init(fetchMusicUseCase: FetchMusicUseCaseProtocol) {
		self.fetchMusicUseCase = fetchMusicUseCase
	}

	func transform(input: Input) -> Output {
		let searchMusicObservable = Observable.merge([
			input.searchTermDriver.distinctUntilChanged().debounce(.milliseconds(300)).asObservable(),
			input.searchButtonTapSignal.withLatestFrom(input.searchTermDriver).asObservable()
		])
		
		let fetchMusicResultObservable = searchMusicObservable.flatMapLatest { [weak self] term -> Observable<Result<[Music], MusicError>> in
			guard let self else { return .empty() }
			return self.fetchMusicUseCase.execute(searchTerm: term)
		}.share()
		
		let fetchMusicSuccessObservabl: Observable<[Music]> = fetchMusicResultObservable.compactMap { result in
			return try? result.get()
		}
		
		let fetchMusicErrorDriver: Driver<MusicError> = fetchMusicResultObservable.compactMap { result in
			switch result {
			case .success:
				return nil
			case let .failure(error):
				return error
			}
		}.asDriver(onErrorJustReturn: .unknown)
		
		let musicSectionDriver: Driver<[SectionModel]> = fetchMusicSuccessObservabl.map({ [weak self] musics in
			guard let self else { return [] }
			let musicItems = musics.map { music in
				let vm = MusicCollectionViewCellViewModel(
					trackName: music.trackName,
					trackTime: self.formatMilliseconds(music.trackTimeMillis),
					imageUrlString: music.artworkUrl100,
					longDescription: music.longDescription
				)
				return Item.music(vm)
			}
			
			return [SectionModel(items: musicItems)]
		}).asDriver(onErrorJustReturn: [])
		
		let loadingSectionDriver: Driver<[SectionModel]> = searchMusicObservable.map { _ in
			return [SectionModel(items: [.loading])]
		}.asDriver(onErrorJustReturn: [])
		
		let dataSourceDriver: Driver<[SectionModel]> = Driver.merge(
			musicSectionDriver,
			loadingSectionDriver
		)
		
		return Output(
			dataSourceDriver: dataSourceDriver,
			errorAlertDriver: fetchMusicErrorDriver
		)
	}
	
	private func formatMilliseconds(_ milliseconds: Int) -> String {
		let totalSeconds = milliseconds / 1000
		
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

extension MusicSearchViewModel {
	struct Input {
		let searchTermDriver: Driver<String>
		let searchButtonTapSignal: Signal<Void>
	}
	
	struct Output {
		let dataSourceDriver: Driver<[SectionModel]>
		let errorAlertDriver: Driver<MusicError>
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
