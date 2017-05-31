//
//  RespondedViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 3/14/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase
import MapKit

var generalBeaconID = "116"
var citizenIDforFeedback = ""

class RespondedViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    // Table fields
    @IBOutlet weak var stop: UILabel!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var citations: UILabel!
    @IBOutlet weak var arrests: UILabel!
    @IBOutlet weak var alerts: UILabel!
    @IBOutlet weak var threats: UILabel!
    @IBOutlet weak var intoxicated: UILabel!
    @IBOutlet weak var weapons: UILabel!
    
    var phoneNumber: String?

    
    @IBOutlet weak var viewDocumentsButton: UIButton!
    @IBAction func MakeCall(_ sender: UIButton) {
        checkIfUserIsLoggedIn()
        phoneNumber = "tel://"+phoneNumber!
        let url: NSURL = NSURL(string: phoneNumber!)!
        UIApplication.shared.openURL(url as URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Driver"
        
        let endStopbutton = UIBarButtonItem(title: "End Stop", style: UIBarButtonItemStyle.done, target: self, action: "endStop")
        self.navigationItem.rightBarButtonItem = endStopbutton
        
//        self.navigationItem.rightBarButtonItem?.title = "End Stop"

        self.viewDocumentsButton.isEnabled = false
        
        self.getBeaconId{(result) -> () in
            if result{
                self.checkIfUserIsLoggedIn()
                self.observeDocumentsUploaded()
            }
        }
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        checkIfUserIsLoggedIn()
//    }
    
    
    func endStop(){
    
        // TODO: Grab citizen id
        print(citizenIDforFeedback)
        
        // TODO: Under beacons, delete the stopID
        let deleteStopIDRef = FIRDatabase.database().reference().child("beacons").child(generalBeaconID).child("stop_id")
        deleteStopIDRef.removeValue()
        
        // TODO: Under beacons, delete citizen
        let deleteCitizenRef = FIRDatabase.database().reference().child("beacons").child(generalBeaconID).child("citizen")
        deleteCitizenRef.removeValue()
        
        // TODO: Under beacons, make isInStop = false
        let beaconRef = FIRDatabase.database().reference().child("beacons").child(generalBeaconID)
        let beaconValues = ["isInStop": false] as [String : Any]
        
        beaconRef.updateChildValues(beaconValues) { (error, ref) in
            if  error != nil {
                print(error ?? "")
                return
            }
        }
        
        // TODO: Perform segue
        self.performSegue(withIdentifier: "endStopSegue", sender: nil)
    }
    
    func getBeaconId(completion: @escaping (_ result: Bool) -> ()) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let beaconId = (dictionary["beacon_id"] as? String)!
                generalBeaconID = beaconId
                completion(true)
            }
        })
    }
    
    
    func observeDocumentsUploaded(){
        FIRDatabase.database().reference().child("beacons").child(generalBeaconID).child("citizen").observe(.value, with: { (snapshot) in
            if snapshot.hasChild("documents"){
                print("Tem sim!")
                self.viewDocumentsButton.isEnabled = true
            }
        })

//        print("BeaconID: ", generalBeaconID)
//        let documentsRef = FIRDatabase.database().reference().child("beacons").child(generalBeaconID).child("citizen")
//        
//        documentsRef.observe(.value, with: { (snapshot) in
//                if  snapshot.hasChild("documents"){
//                    print("Tem sim!")
//                    self.viewDocumentsButton.isEnabled = true
//                }
//        }, withCancel: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            let beaconId = generalBeaconID
            var citizenuid = "id"
            print("BeaconID: ", generalBeaconID)
            
            FIRDatabase.database().reference().child("beacons").child(beaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    citizenuid = (dictionary["uid"] as? String)!
                    citizenIDforFeedback = citizenuid
                    //Check for id
                    FIRDatabase.database().reference().child("citizen").child(citizenuid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let name = (dictionary["first_name"] as? String)!
                            let last_name = (dictionary["last_name"] as? String)!
//                            let gender = (dictionary["gender"] as? String)!
                            let gender = "Female"
//                            let age = (dictionary["license_number"] as? String)!
//                            let language = (dictionary["language"] as? String)!
                            let language = "English"
                            let zipcode = dictionary["zipcode"] as? String
                            self.phoneNumber = (dictionary["phone_number"] as? String)!
                            let photoPath = (dictionary["photo"] as? String)!
                            
                            self.downloadProfileImage(path: photoPath)
                            
                            self.nameLabel.text = name + " " + last_name
                            self.genderLabel.text = gender + " - " + "25"
                            self.languageLabel.text = language
                            
                            // Get City and state from zipcode
                            let geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(zipcode!) {
                                (placemarks, error) -> Void in
                                // Placemarks is an optional array of CLPlacemarks, first item in array is best guess of Address
                                
                                if let placemark = placemarks?[0] {
                                    
                                    //                        print(placemark.addressDictionary)
                                    
                                    let city = placemark.locality ?? ""
                                    let state = placemark.administrativeArea ?? ""
                                    self.stateLabel.text =  city + ", " + state
                                    
                                }
                                
                            }
                            
                            
                            
                            // Fill out table with previous stops interactions
                        FIRDatabase.database().reference().child("citizen").child(citizenuid).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String: AnyObject]{
                                    self.stop.text = String((dictionary["stops"] as? Int)!)
                                    self.warning.text = String((dictionary["warnings"] as? Int)!)
                                    self.citations.text = String((dictionary["citations"] as? Int)!)
                                    self.arrests.text = String((dictionary["arrests"] as? Int)!)
                                    self.alerts.text = String((dictionary["alerts"] as? Int)!)
                                    self.threats.text = String((dictionary["threats"] as? Int)!)
                                    self.intoxicated.text = String((dictionary["intoxicated"] as? Int)!)
                                    self.weapons.text = String((dictionary["weapons"] as? Int)!)
                                }
                            })
                        }
                        
                        print (snapshot)
                    })
                }
                print (snapshot)
            })
            
            print("CITIZEN ID GOT IT!")
            print(citizenuid)            
        }
    }
    
    func downloadProfileImage(path: String){
        let storage = FIRStorage.storage().reference()
        let profile = storage.child(path)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*1000) { (data, error) in
            if error == nil {
                self.profileImage.image = UIImage(data: data!)
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription ?? "")
            }
        }
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
