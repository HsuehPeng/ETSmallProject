import RxSwift

public protocol FetchMusicRepositoryProtocol {
	typealias FetchResult = Result<[Music], MusicError>
	
	func fetch(searchTerm: String) -> Observable<FetchResult>
}
