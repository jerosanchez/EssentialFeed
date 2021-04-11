//
//  Copyright (c) 2021 Jero Sanchez. All rights reserved.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 42)
}
