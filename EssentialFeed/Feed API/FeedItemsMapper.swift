//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        if response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return root.items
        } else {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
