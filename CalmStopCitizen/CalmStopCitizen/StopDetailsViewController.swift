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
    @IBOutlet weak var officerPhoto: UIImageView!
    
    var stopIndex = stopID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.officerPhoto.layer.cornerRadius = self.officerPhoto.frame.size.width/2
        self.officerPhoto.clipsToBounds = true

        
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
                    let number = place.subThoroughfare ?? ""
                    let street = place.thoroughfare ?? ""
                    let city = place.locality ?? ""
                    let state = place.administrativeArea ?? ""
                    let zipcode = place.postalCode ?? ""
                    let country = place.isoCountryCode ?? ""
                    
                    self.addressLabel.text =
                        number + " " + street + ", " + city + " " + state + " " + zipcode + ", " + country
                    
                }
            }
        }
        
        // Get citizen name
        FIRDatabase.database().reference().child("officer").child("14567").child(arrayStopData[stopIndex].officerID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let name = dictionary["last_name"] as? String
                let gender = dictionary["gender"] as? String
                //let zipcode = dictionary["zip_code"] as? String
                let photo = dictionary["photo"] as? String
                
                self.nameLabel.text = "Officer " + name!
                
                self.downloadProfileImage(photoPath: photo ?? " ")
                
                // Get City and state from zipcode
                // let geocoder = CLGeocoder()
                // geocoder.geocodeAddressString(zipcode!) {
                    //(placemarks, error) -> Void in
                    // Placemarks is an optional array of CLPlacemarks, first item in array is best guess of Address
                    
                    //if let placemark = placemarks?[0] {
                        
                        //                        print(placemark.addressDictionary)
                        
                        //let city = placemark.locality ?? ""
                        //let state = placemark.administrativeArea ?? ""
                        //self.driverZipcodeLabel.text =  city + ", " + state
                        
                    //}
                    
                //}
            }
        })
        
        dateAndTime.text = arrayStopData[stopIndex].date! + ", " + arrayStopData[stopIndex].time!
        reasonLabel.text = arrayStopData[stopIndex].reason
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadProfileImage(photoPath: String){
        if (photoPath != " "){
            let database = FIRDatabase.database().reference()
            let storage = FIRStorage.storage().reference()
            let profile = storage.child(photoPath)
            
            // Download Images
            profile.data(withMaxSize: 1*1000*1000) { (data, error) in
                if error == nil {
                    self.officerPhoto.image = UIImage(data: data!)
                    self.officerPhoto.layer.cornerRadius = self.officerPhoto.frame.size.width/2
                    self.officerPhoto.clipsToBounds = true
                }
                else {
                    print(error?.localizedDescription ?? "Error downloading image!")
                }
            }
        }
        else{
            self.officerPhoto.layer.cornerRadius = self.officerPhoto.frame.size.width/2
            self.officerPhoto.clipsToBounds = true
            
        }
        
        
    }
    
}
