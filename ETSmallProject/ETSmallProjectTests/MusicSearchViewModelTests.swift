import XCTest
import RxCocoa
import RxTest
import RxSwift
@testable import ETSmallProject

final class MusicSearchViewModelTests: XCTestCase {
	var viewModel: MusicSearchViewModel!
	var mockFetchMusicUseCase: MockFetchMusicUseCase!
	var musicManagerUseCaseSpy: MusicManagerUseCaseSpy!
	var scheduler: TestScheduler!
	var disposeBag: DisposeBag!
	
	override func setUp() {
		super.setUp()
		mockFetchMusicUseCase = MockFetchMusicUseCase()
		musicManagerUseCaseSpy = MusicManagerUseCaseSpy()
		viewModel = MusicSearchViewModel(fetchMusicUseCase: mockFetchMusicUseCase, musicManagerUseCase: musicManagerUseCaseSpy)
		scheduler = TestScheduler(initialClock: 0)
		disposeBag = DisposeBag()
	}
	
	override func tearDown() {
		viewModel = nil
		mockFetchMusicUseCase = nil
		musicManagerUseCaseSpy = nil
		scheduler = nil
		disposeBag = nil
		super.tearDown()
	}
	
	func test_succeededToSearchMusic_returnSection() {
		let searchTermObservable: TestableObservable<String> = scheduler.createHotObservable([.next(0, "searchTerm")])
		let searchButtonTapObservable: TestableObservable<Void> = scheduler.createHotObservable([.next(100, ())])
		let cellItemTapObservable: TestableObservable<IndexPath> = scheduler.createHotObservable([])
		let music = Music(
			trackName: "",
			trackTimeMillis: 0,
			artworkUrl100: "",
			longDescription: "",
			previewUrl: ""
		)
		mockFetchMusicUseCase.fetchResult = .just(.success([music]))
		let resultObserver = scheduler.createObserver([MusicSearchViewModel.SectionModel].self)

		let expectedMusicCellVMs = [music.mapToMusicCellViewModel()]
		let expectedSections = [MusicSearchViewModel.SectionModel(items: expectedMusicCellVMs)]
		
		let output = viewModel.transform(
			input: .init(
				searchTermDriver: searchTermObservable.asDriver(onErrorJustReturn: ""),
				searchButtonTapSignal: searchButtonTapObservable.asSignal(onErrorJustReturn: ()),
				didTapCellItemSignal: cellItemTapObservable.asSignal(onErrorJustReturn: IndexPath(item: 0, section: 0))
			)
		)
		output.dataSourceDriver.skip(2).asObservable().subscribe(resultObserver).disposed(by: disposeBag)
		
		scheduler.start()

		let results = resultObserver.events.compactMap { $0.value.element }
		XCTAssertEqual(results, [expectedSections])
	}
	
	func test_failedToSearchMusic_returnNoMusicItems() {
		let searchTermObservable: TestableObservable<String> = scheduler.createHotObservable([.next(0, "searchTerm")])
		let searchButtonTapObservable: TestableObservable<Void> = scheduler.createHotObservable([.next(100, ())])
		let cellItemTapObservable: TestableObservable<IndexPath> = scheduler.createHotObservable([])
		mockFetchMusicUseCase.fetchResult = .just(.failure(.unknown))
		let resultObserver = scheduler.createObserver([MusicSearchViewModel.SectionModel].self)

		let output = viewModel.transform(
			input: .init(
				searchTermDriver: searchTermObservable.asDriver(onErrorJustReturn: ""),
				searchButtonTapSignal: searchButtonTapObservable.asSignal(onErrorJustReturn: ()),
				didTapCellItemSignal: cellItemTapObservable.asSignal(onErrorJustReturn: IndexPath(item: 0, section: 0))
			)
		)
		output.dataSourceDriver.skip(2).asObservable().subscribe(resultObserver).disposed(by: disposeBag)
		
		scheduler.start()
		
		let results = resultObserver.events.compactMap { $0.value.element }
		XCTAssertEqual(results, [])
	}
	
	func test_failedToSearchMusic_errorAlertDriverEvent() {
		let searchTermObservable: TestableObservable<String> = scheduler.createHotObservable([.next(0, "searchTerm")])
		let searchButtonTapObservable: TestableObservable<Void> = scheduler.createHotObservable([.next(100, ())])
		let cellItemTapObservable: TestableObservable<IndexPath> = scheduler.createHotObservable([])
		mockFetchMusicUseCase.fetchResult = .just(.failure(.unknown))
		let resultObserver = scheduler.createObserver(MusicError.self)
		
		let output = viewModel.transform(
			input: .init(
				searchTermDriver: searchTermObservable.asDriver(onErrorJustReturn: ""),
				searchButtonTapSignal: searchButtonTapObservable.asSignal(onErrorJustReturn: ()),
				didTapCellItemSignal: cellItemTapObservable.asSignal(onErrorJustReturn: IndexPath(item: 0, section: 0))
			)
		)
		
		output.errorAlertDriver.asObservable().subscribe(resultObserver).disposed(by: disposeBag)
		
		scheduler.start()
		
		let results = resultObserver.events.compactMap { $0.value.element }
		XCTAssertEqual(results, [.unknown])
	}
	
	class MockFetchMusicUseCase: FetchMusicUseCaseProtocol {
		var fetchResult: Observable<Result<[Music], MusicError>>?
		
		func execute(searchTerm: String) -> Observable<Result<[Music], MusicError>> {
			guard let fetchResult else {
				fatalError("You forget to set the fetchResult")
			}
			
			return fetchResult
		}
	}
	
	class MusicManagerUseCaseSpy: MusicManagerUseCaseProtocol {
		private(set) var actions = [Action]()
		
		func start(from url: URL) {
			actions.append(.start)
		}
		
		func pause() {
			actions.append(.pause)
		}
		
		func resume() {
			actions.append(.resume)
		}
		
		func reset() {
			actions.append(.reset)
		}
		
		enum Action {
			case start
			case pause
			case resume
			case reset
		}
	}

}
