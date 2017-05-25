//
//  Stop.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/27/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import MapKit

class Stop: NSObject {
    var citizenID: String?
    var date: String?
    var lat: String?
    var long: String?
    var officerID: String?
    var reason: String?
    var time: String?
    var threadID: String?
    
    init(dictionary: [String: Any]) {
        self.citizenID = dictionary["citizenID"] as? String
        self.date = dictionary["date"] as? String
        self.lat = dictionary["lat"] as? String
        self.long = dictionary["long"] as? String
        self.officerID = dictionary["officerID"] as? String
        self.reason = dictionary["reason"] as? String
        self.time = dictionary["time"] as? String
        self.threadID = dictionary["threadID"] as? String

    }
}
