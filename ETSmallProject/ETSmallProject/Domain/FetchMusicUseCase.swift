import RxSwift

protocol FetchMusicUseCaseProtocol {
	typealias FetchResult = Result<[Music], MusicError>
	
	func execute(searchTerm: String) -> Observable<FetchResult>
}

final class FetchMusicUseCase: FetchMusicUseCaseProtocol {
	private let fetchMusicRepository: FetchMusicRepositoryProtocol
	
	init(fetchMusicRepository: FetchMusicRepositoryProtocol) {
		self.fetchMusicRepository = fetchMusicRepository
	}
	
	func execute(searchTerm: String) -> Observable<FetchResult> {
		fetchMusicRepository.fetch(searchTerm: searchTerm)
	}
}
