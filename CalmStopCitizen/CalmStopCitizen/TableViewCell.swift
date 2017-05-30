//
//  TableViewCell.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/27/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import MapKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dataTimeLabel: UILabel!
    
    @IBOutlet weak var driverNameLabel: UILabel!
    
}
