import Foundation
import Differentiator
import RxCocoa
import RxSwift

final class MusicSearchViewModel {
	private let fetchMusicUseCase: FetchMusicUseCaseProtocol
	private let musicManagerUseCase: MusicManagerUseCaseProtocol
	private let disposebag = DisposeBag()
	
	private let musicCellVMsRelay = BehaviorRelay<[MusicCollectionViewCellViewModel]>(value: [])
	private let errorRelay = PublishRelay<MusicError>()
	private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
	private let playingIndexRelay = BehaviorRelay<Int?>(value: nil)
	
	init(
		fetchMusicUseCase: FetchMusicUseCaseProtocol,
		musicManagerUseCase: MusicManagerUseCaseProtocol
	) {
		self.fetchMusicUseCase = fetchMusicUseCase
		self.musicManagerUseCase = musicManagerUseCase
	}

	func transform(input: Input) -> Output {
		input.didTapCellItemSignal.emit(with: self, onNext: { owner, indexPath in
			let selectedIndex = indexPath.item
			let selectedMusicItemVM = owner.musicCellVMsRelay.value[selectedIndex]
			
			guard let previousSelectedIndex = owner.playingIndexRelay.value else {
				selectedMusicItemVM.togglePlayState()
				owner.playingIndexRelay.accept(selectedIndex)
				owner.musicManagerUseCase.start(from: URL(string: selectedMusicItemVM.music.previewUrl)!)
				return
			}
			
			if selectedIndex == previousSelectedIndex {
				selectedMusicItemVM.togglePlayState()
				owner.playingIndexRelay.accept(previousSelectedIndex)
				if selectedMusicItemVM.playState == .playing {
					owner.musicManagerUseCase.resume()
				} else if selectedMusicItemVM.playState == .pause {
					owner.musicManagerUseCase.pause()
				}
			} else {
				owner.musicCellVMsRelay.value[previousSelectedIndex].removePlayState()
				selectedMusicItemVM.togglePlayState()
				owner.playingIndexRelay.accept(selectedIndex)
				owner.musicManagerUseCase.start(from: URL(string: selectedMusicItemVM.music.previewUrl)!)
			}
		}).disposed(by: disposebag)
		
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
						music: music,
						trackName: music.trackName,
						trackTime: owner.formatMilliseconds(music.trackTimeMillis),
						imageUrlString: music.artworkUrl100,
						longDescription: music.longDescription
					)
				}
				owner.musicCellVMsRelay.accept(musicCellVMs)
			case let .failure(error):
				owner.errorRelay.accept(error)
			}
		})
		.disposed(by: disposebag)
		
		let musicSectionDriver: Driver<[SectionModel]> = Driver.combineLatest(
			musicCellVMsRelay.asDriver(),
			playingIndexRelay.asDriver()
		).map { [weak self] musicCellVMs, selectedMusicState in
			guard let self else { return [] }
			
			let musicItems = musicCellVMs.map({ Item.music($0) })
			return [SectionModel(items: musicItems)]
		}
		
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
		let didTapCellItemSignal: Signal<IndexPath>
	}
	
	struct Output {
		let dataSourceDriver: Driver<[SectionModel]>
		let errorAlertDriver: Driver<MusicError>
	}
	
	struct Constants {
		static let searchMusicTitle = "Search Music"
		static let searchPlaceHolder = "Enter keyword here"
		static let searchButtonTitle = "Search"
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
