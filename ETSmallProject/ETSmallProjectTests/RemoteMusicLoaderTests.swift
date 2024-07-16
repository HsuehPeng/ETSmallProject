import XCTest
import RxSwift
import RxBlocking
import ETSmallProject

class RemoteMusicLoaderTests: XCTestCase {
	private var sut: RemoteMusicLoader!
	private var httpClient: MockHTTPClient!
	private let asyneScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
	
	override func setUp() {
		super.setUp()
		httpClient = MockHTTPClient()
		sut = RemoteMusicLoader(httpClient: httpClient)
	}
	
	override func tearDown() {
		sut = nil
		httpClient = nil
		super.tearDown()
	}
	
	func test_fetch_withValidData_emitsSuccess() {
		let searchTerm = "test"
		let data = validMusicData()
		httpClient.stubbedRequestResult = .success(data)
		
		let fetchObservable = sut.fetch(searchTerm: searchTerm).subscribe(on: asyneScheduler)
		let result = try? fetchObservable.observe(on: MainScheduler.instance).toBlocking().first()
		
		switch result {
		case let .success(musics):
			XCTAssertNotNil(musics)
		default:
			XCTFail("Expected success, but got \(String(describing: result))")
		}
	}
	
	func test_fetch_withInvalidData_emitsFailure() {
		let searchTerm = "test"
		let data = invalidMusicData()
		httpClient.stubbedRequestResult = .success(data)
		
		let fetchObservable = sut.fetch(searchTerm: searchTerm).subscribe(on: asyneScheduler)
		let result = try? fetchObservable.observe(on: MainScheduler.instance).toBlocking().first()
		
		switch result {
		case .failure(let error):
			XCTAssertEqual(error, .invalidData)
		default:
			XCTFail("Expected failure with invalid data, but got \(String(describing: result))")
		}
	}

	private func validMusicData() -> Data {
		let item: [String: Any] = [
			"trackId": 111111,
			"trackName": "Test track name",
			"trackTimeMillis": 222222,
			"artworkUrl100": "Test artworkUrl100",
			"longDescription": "Test longDescription",
			"previewUrl": "Test previewUrl",
		]
		return makeMusicJSON([item])
	}
	
	private func invalidMusicData() -> Data {
		return Data("invalid json".utf8)
	}
	
	private func makeMusicJSON(_ items: [[String: Any]]) -> Data {
		let json = ["results": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private class MockHTTPClient: HTTPClient {
		var stubbedRequestResult: Result<Data, NetworkError>?

		func request(endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
			guard let stubbedRequestResult else {
				fatalError("Forget to set stubbedRequestResult")
			}
			
			completion(stubbedRequestResult)
		}
	}
}
