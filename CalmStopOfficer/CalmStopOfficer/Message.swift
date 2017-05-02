//
//  Message.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/17/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit

class Message: NSObject {
    var author: String?
    var content: String?
    var timestamp: NSNumber?

    init(dictionary: [String: Any]) {
        self.author = dictionary["authorID"] as? String
        self.content = dictionary["content"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
}
