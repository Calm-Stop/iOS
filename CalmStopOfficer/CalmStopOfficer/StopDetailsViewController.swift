//
//  StopDetailsViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/5/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import MapKit

class StopDetailsViewController: UIViewController {

    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var driverZipcodeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
