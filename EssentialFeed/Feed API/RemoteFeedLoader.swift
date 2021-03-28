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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
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
            return .success(items.toModel())
        } else {
            return .failure(.invalidData)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModel() -> [FeedItem] {
        map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
