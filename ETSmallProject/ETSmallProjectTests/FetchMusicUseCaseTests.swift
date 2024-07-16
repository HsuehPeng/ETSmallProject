import XCTest
import RxSwift
import RxBlocking
import ETSmallProject

final class FetchMusicUseCaseTests: XCTestCase {
	private var sut: FetchMusicUseCase!
	private var fetchMusicRepository: MockFetchMusicRepository!

	override func setUp() {
		super.setUp()
		fetchMusicRepository = MockFetchMusicRepository()
		sut = FetchMusicUseCase(fetchMusicRepository: fetchMusicRepository)
	}

	override func tearDown() {
		sut = nil
		fetchMusicRepository = nil
		super.tearDown()
	}

	func test_execute_withSuccess() {
		let fetchResult: Result<[Music], MusicError> = .success([anyMusic()])
		fetchMusicRepository.stubbedFetchResult = Observable.just(fetchResult)

		let result = try? sut.execute(searchTerm: searchTerm).toBlocking().first()

		XCTAssertEqual(result, fetchResult)
	}
	
	func test_execute_withFailure() {
		let fetchResult: Result<[Music], MusicError> = .failure(.unknown)
		fetchMusicRepository.stubbedFetchResult = Observable.just(fetchResult)

		let result = try? sut.execute(searchTerm: searchTerm).toBlocking().first()

		XCTAssertEqual(result, fetchResult)
	}
	
	private class MockFetchMusicRepository: FetchMusicRepositoryProtocol {
		var stubbedFetchResult: Observable<FetchResult>?

		func fetch(searchTerm: String) -> Observable<FetchResult> {
			guard let stubbedFetchResult else {
				fatalError("Forget to set stubbedFetchResult")
			}
			
			return stubbedFetchResult
		}
	}
	
	private let searchTerm = "Test search term"
	
	private func anyMusic() -> Music {
		.init(
			trackName: "Any name",
			trackTimeMillis: 1,
			artworkUrl100: "artworkUrl100",
			longDescription: "longDescription",
			previewUrl: "previewUrl"
		)
	}
}


