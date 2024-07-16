import Foundation
import RxSwift

public final class RemoteMusicLoader: FetchMusicRepositoryProtocol {
	private let httpClient: HTTPClient
	
	public init(httpClient: HTTPClient) {
		self.httpClient = httpClient
	}
	
	public func fetch(searchTerm: String) -> Observable<FetchResult> {
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
					observer.onNext(.failure(.network(error)))
				}
				observer.onCompleted()
			}
			
			return Disposables.create()
		}
	}
}
