//
//  Message.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/17/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit

class Message: NSObject {
    var authorID: String?
    var content: String?
    var threadID: String?
    var timestamp: NSNumber?
    
    init(dictionary: [String: Any]) {
        self.authorID = dictionary["authorID"] as? String
        self.content = dictionary["content"] as? String
        self.threadID = dictionary["threadID"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
}
