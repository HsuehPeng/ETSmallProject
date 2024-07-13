import RxSwift

final class RemoteFetchMusicUseCase: FetchMusicUseCaseProtocol {
	func execute(searchTerm: String) -> Observable<FetchResult> {
		let musics: [Music] = [
			.init(id: "1", trackName: "Track name1", trackTimeMillis: 7154613, artworkUrl100: "", longDescription: "longDescription"),
			.init(id: "1", trackName: "Track name1", trackTimeMillis: 7154613, artworkUrl100: "", longDescription: "longDescription"),
			.init(id: "1", trackName: "Track name1", trackTimeMillis: 7154613, artworkUrl100: "", longDescription: "longDescription"),
			.init(id: "1", trackName: "Track name1", trackTimeMillis: 7154613, artworkUrl100: "", longDescription: "longDescription")
		]
		
//		return Observable.just(.success(musics)).delay(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
		return Observable.just(.failure(.search)).delay(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
	}
}
