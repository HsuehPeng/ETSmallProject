import Foundation
import RxSwift

final class RemoteFetchMusicUseCase: FetchMusicUseCaseProtocol {
	private let httpClient: HTTPClient
	
	init(httpClient: HTTPClient) {
		self.httpClient = httpClient
	}
	
	func execute(searchTerm: String) -> Observable<FetchResult> {
		let endPoint = MusicSearchEndpoint(searchTerm: searchTerm)
		return Observable.create { [weak self] observer in
			self?.httpClient.request(endpoint: endPoint) { result in
				switch result {
				case let .success(data):
					do {
						let musicDTORoot = try JSONDecoder().decode(MusicDTORoot.self, from: data)
						observer.onNext(.success(musicDTORoot.mapToDomainMusics()))
					} catch {
						observer.onNext(.failure(.invalidData))
					}
				case let .failure(error):
					observer.onNext(.failure(.search))
				}
				observer.onCompleted()
			}
			
			return Disposables.create()
		}
	}
}
