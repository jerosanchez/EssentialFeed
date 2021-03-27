//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

class HTTPClient {
    var requestedURLs = [URL]()
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClient()
        let _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
}
