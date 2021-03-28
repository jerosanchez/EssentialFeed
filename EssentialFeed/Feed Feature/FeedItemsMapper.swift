//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import Foundation

class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var model: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedItem] {
        if response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return root.items.map { $0.model }
        } else {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}
