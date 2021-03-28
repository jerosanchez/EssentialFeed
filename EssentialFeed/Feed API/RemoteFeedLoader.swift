//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, with: response))
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    // Mark: - Helpers
    
    private static func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        if let items = try? FeedItemsMapper.map(data, from: response) {
            return .success(items)
        } else {
            return .failure(.invalidData)
        }
    }
}
