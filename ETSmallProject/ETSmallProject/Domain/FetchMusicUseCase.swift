import RxSwift

public protocol FetchMusicUseCaseProtocol {
	typealias FetchResult = Result<[Music], MusicError>
	
	func execute(searchTerm: String) -> Observable<FetchResult>
}

public final class FetchMusicUseCase: FetchMusicUseCaseProtocol {
	private let fetchMusicRepository: FetchMusicRepositoryProtocol
	
	public init(fetchMusicRepository: FetchMusicRepositoryProtocol) {
		self.fetchMusicRepository = fetchMusicRepository
	}
	
	public func execute(searchTerm: String) -> Observable<FetchResult> {
		fetchMusicRepository.fetch(searchTerm: searchTerm)
	}
}
