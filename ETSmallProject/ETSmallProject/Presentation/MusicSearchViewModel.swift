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
	private let playingMusicStateRelay = BehaviorRelay<PlayMusicStateModel>(value: .init(index: nil, music: nil, state: .none))
	
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
			let selectedMusic = owner.musicCellVMsRelay.value[selectedIndex].music
			let previousPlayMusicStateModel = owner.playingMusicStateRelay.value
			
			if let prevIndex = previousPlayMusicStateModel.index {
				owner.musicCellVMsRelay.value[prevIndex].playState = .none
			}
	
			if previousPlayMusicStateModel.index == selectedIndex {
				switch previousPlayMusicStateModel.state {
				case .finished, .none:
					owner.playingMusicStateRelay.accept(.init(index: selectedIndex, music: selectedMusic, state: .start))
				case .pause:
					owner.playingMusicStateRelay.accept(.init(index: selectedIndex, music: selectedMusic, state: .resumed))
				case .resumed, .start:
					owner.playingMusicStateRelay.accept(.init(index: selectedIndex, music: selectedMusic, state: .pause))
				}
			} else {
				let nextplayMusicStateModel = PlayMusicStateModel(
					index: selectedIndex,
					music: selectedMusic,
					state: .start
				)
				owner.playingMusicStateRelay.accept(nextplayMusicStateModel)
			}
		}).disposed(by: disposebag)
		
		let searchMusicObservable = Observable.merge([
			input.searchTermDriver.skip(1).distinctUntilChanged().debounce(.milliseconds(300)).asObservable(),
			input.searchButtonTapSignal.withLatestFrom(input.searchTermDriver).asObservable()
		])
		.withUnretained(self)
		.do(onNext: { owner, _ in
			owner.isLoadingRelay.accept(true)
			owner.playingMusicStateRelay.accept(.init(index: nil, music: nil, state: .none))
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
		
		let playingMusicStateDriver = playingMusicStateRelay.asDriver()
		let musicCellVMsDriver = musicCellVMsRelay.asDriver()
		
		playingMusicStateDriver
			.drive(with: self, onNext: { owner, musicStateModel in
				guard let music = musicStateModel.music, let url = URL(string: music.previewUrl) else {
					owner.musicManagerUseCase.reset()
					return
				}
				switch musicStateModel.state {
				case .start:
					owner.musicManagerUseCase.start(from: url)
				case .pause:
					owner.musicManagerUseCase.pause()
				case .resumed:
					owner.musicManagerUseCase.resume()
				case .finished, .none:
					owner.musicManagerUseCase.reset()
				}
			}).disposed(by: disposebag)
		
		let dataSourceDriver: Driver<[SectionModel]> = Driver.combineLatest(
			musicCellVMsDriver,
			playingMusicStateDriver
		).map { musicCellVMs, stateModel in
			guard let selectedIndex = stateModel.index else {
				return [SectionModel(items: musicCellVMs)]
			}
			
			let musicCellVMs = musicCellVMs
			musicCellVMs[selectedIndex].playState = stateModel.state
			return [SectionModel(items: musicCellVMs)]
		}
		
		return Output(
			dataSourceDriver: dataSourceDriver,
			errorAlertDriver: errorRelay.asDriver(onErrorJustReturn: .unknown),
			isLoadingDriver: isLoadingRelay.asDriver()
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
		let isLoadingDriver: Driver<Bool>
	}
	
	struct Constants {
		static let searchMusicTitle = "Search Music"
		static let searchPlaceHolder = "Enter keyword here"
		static let searchButtonTitle = "Search"
	}
	
	struct SectionModel: SectionModelType {
		var items: [MusicCollectionViewCellViewModel]

		init(original: SectionModel, items: [MusicCollectionViewCellViewModel]) {
			self = original
			self.items = items
		}
		
		init(items: [MusicCollectionViewCellViewModel]) {
			self.items = items
		}
	}
	
	struct PlayMusicStateModel {
		let index: Int?
		let music: Music?
		let state: PlayState
	}
}


