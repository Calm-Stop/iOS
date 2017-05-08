//
//  StopDetailsViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/5/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class StopDetailsViewController: UIViewController {

    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var driverZipcodeLabel: UILabel!
    
    var stopIndex = stopID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data for map
        let lat = (arrayStopData[stopIndex].lat! as NSString).doubleValue as CLLocationDegrees
        let long = (arrayStopData[stopIndex].long! as NSString).doubleValue as CLLocationDegrees
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        detailMap.setRegion(region, animated: true)
        detailMap.addAnnotation(annotation)

        let stopLocation = CLLocation(latitude: lat, longitude: long)
        
        //Geocode
        CLGeocoder().reverseGeocodeLocation(stopLocation) { (placemark, error) in
            if error != nil {
                print ("error")
            }
            else{
                if let place = placemark?[0] {
                        self.addressLabel.text =
                            place.subThoroughfare! + " " + place.thoroughfare! + ", " + place.locality! + " " + place.administrativeArea! + " " + place.postalCode! + ", " + place.isoCountryCode!
                }
            }
        }
        
        // Get citizen name
        FIRDatabase.database().reference().child("citizen").child(arrayStopData[stopIndex].citizenID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let name = dictionary["first_name"] as? String
                let gender = dictionary["gender"] as? String
                let zipcode = dictionary["zip_code"] as? String


                self.nameLabel.text = name
                self.genderLabel.text = gender
                self.driverZipcodeLabel.text = zipcode

            }
        })
        
        dateAndTime.text = arrayStopData[stopIndex].date! + ", " + arrayStopData[stopIndex].time!
        reasonLabel.text = arrayStopData[stopIndex].reason

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
