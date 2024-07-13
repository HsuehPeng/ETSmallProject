import RxSwift

protocol FetchMusicUseCaseProtocol {
	typealias FetchResult = Result<[Music], MusicError>
	
	func execute(searchTerm: String) -> Observable<FetchResult>
}
