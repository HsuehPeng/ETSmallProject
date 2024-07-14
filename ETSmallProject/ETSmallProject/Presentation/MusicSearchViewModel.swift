import Foundation
import Differentiator
import RxCocoa
import RxSwift

final class MusicSearchViewModel {
	private let fetchMusicUseCase: FetchMusicUseCaseProtocol
	private let disposebag = DisposeBag()
	private let musicItemVMsBehaviorRelay = BehaviorRelay<[MusicCollectionViewCellViewModel]>(value: [])
	private let errorRelay = PublishRelay<MusicError>()
	private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
	
	init(fetchMusicUseCase: FetchMusicUseCaseProtocol) {
		self.fetchMusicUseCase = fetchMusicUseCase
	}

	func transform(input: Input) -> Output {
		let searchMusicObservable = Observable.merge([
			input.searchTermDriver.skip(1).distinctUntilChanged().debounce(.milliseconds(300)).asObservable(),
			input.searchButtonTapSignal.withLatestFrom(input.searchTermDriver).asObservable()
		])
		.withUnretained(self)
		.do(onNext: { owner, _ in
			owner.isLoadingRelay.accept(true)
		})
		.share()
		
		searchMusicObservable.flatMapLatest { owner, term -> Observable<Result<[Music], MusicError>> in
			owner.fetchMusicUseCase.execute(searchTerm: term)
		}.subscribe(with: self, onNext: { owner, result in
			owner.isLoadingRelay.accept(false)

			switch result {
			case let .success(musics):
				let musicCellVMs = musics.map { music in
					MusicCollectionViewCellViewModel(
						trackName: music.trackName,
						trackTime: owner.formatMilliseconds(music.trackTimeMillis),
						imageUrlString: music.artworkUrl100,
						longDescription: music.longDescription
					)
				}
				owner.musicItemVMsBehaviorRelay.accept(musicCellVMs)
			case let .failure(error):
				owner.errorRelay.accept(error)
			}
		})
		.disposed(by: disposebag)
		
		let musicSectionDriver: Driver<[SectionModel]> = musicItemVMsBehaviorRelay.map { musicCellVMs in
			let musicItems = musicCellVMs.map({ Item.music($0) })
			return [SectionModel(items: musicItems)]
		}.asDriver(onErrorJustReturn: [])
		
		let loadingSectionDriver: Driver<[SectionModel]> = isLoadingRelay.map { isLoading in
			return isLoading ? [SectionModel(items: [.loading])] : []
		}.asDriver(onErrorJustReturn: [SectionModel(items: [.loading])])
		
		return Output(
			dataSourceDriver: Driver.merge(musicSectionDriver, loadingSectionDriver),
			errorAlertDriver: errorRelay.asDriver(onErrorJustReturn: .unknown)
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
