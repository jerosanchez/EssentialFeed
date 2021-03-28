//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversErrorOnHTTPClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 42)
        
        var receivedErrors = [RemoteFeedLoader.Error?]()
        sut.load { receivedErrors.append($0) }
        
        client.complete(withError: clientError)
        
        XCTAssertEqual(receivedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
                
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var receivedErrors = [RemoteFeedLoader.Error?]()
            sut.load { receivedErrors.append($0) }

            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(receivedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
                
        var receivedErrors = [RemoteFeedLoader.Error?]()
        sut.load { receivedErrors.append($0) }
        
        let emptyJSON = "invalid JSON".data(using: .utf8)!
        client.complete(withStatusCode: 200, data: emptyJSON)
        
        XCTAssertEqual(receivedErrors, [.invalidData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url ?? anyURL(), client: client)

        return (sut, client)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var receivedMessages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            receivedMessages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            receivedMessages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            receivedMessages[index].completion(.success(data, response))
        }
    }
}
