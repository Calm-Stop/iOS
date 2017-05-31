//
//  ReportViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/30/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class ReportViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var warningBtn: UIButton!
    @IBOutlet weak var citationBtn: UIButton!
    @IBOutlet weak var arrestedBtn: UIButton!
    @IBOutlet weak var threatBtn: UIButton!
    @IBOutlet weak var intoxicatedBtn: UIButton!
    @IBOutlet weak var weaponBtn: UIButton!
    @IBOutlet weak var alertBtn: UIButton!
    
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var driverGenderAge: UILabel!
    @IBOutlet weak var driverLocation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        beaconIDString =
        
        driverImage.layer.cornerRadius = self.driverImage.frame.width/2
        driverImage.clipsToBounds = true

        
        checkIfUserIsLoggedIn()

    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
//            let beaconId = beaconIDString
//            var citizenUid = "id"
            
//            FIRDatabase.database().reference().child("beacons").child(beaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                if let dictionary = snapshot.value as? [String: AnyObject]{
//                    citizenUid = (dictionary["uid"] as? String)!
                    //Check for id
                    FIRDatabase.database().reference().child("citizen").child(citizenIDforFeedback).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let first_name = (dictionary["first_name"] as? String)!
                            let last_name = (dictionary["last_name"] as? String)!
                            let gender = (dictionary["gender"] as? String)!
                            let zipcode = (dictionary["zipcode"] as? String)!
                            let photoRef = dictionary["photo"] as? String
                            
                            
                            // fill out view with info from database
                            self.driverName.text = first_name + " " + last_name
                            self.driverGenderAge.text = gender
                            self.driverLocation.text = zipcode
                            
                            //download image from firebase
                            let storage = FIRStorage.storage().reference()
                            let driverPhoto = storage.child(photoRef!)
                            driverPhoto.data(withMaxSize: 1*1000*1000) { (data, error) in
                                if error == nil {
                                    self.driverImage.image = UIImage(data: data!)
                                }
                                else {
                                    print(error?.localizedDescription)
                                }
                            }
                        }
                        
                        print (snapshot)
                    })
//                }
//                print (snapshot)
//            })
            
            print("got officer info")
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    
    @IBAction func submitReport(_ sender: Any) {
//        let beaconId = beaconIDString
//        var citizenUid = "id"
//        print("BeaconID: ", beaconId)
        
//        FIRDatabase.database().reference().child("beacons").child(beaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
        
//            if let dictionary = snapshot.value as? [String: AnyObject]{
//                citizenUid = (dictionary["uid"] as? String)!
        
                //Check for id
                FIRDatabase.database().reference().child("citizen").child(citizenIDforFeedback).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        var stops = (dictionary["stops"] as? Int)!
                        var warnings = (dictionary["warnings"] as? Int)!
                        var citations = (dictionary["citations"] as? Int)!
                        var arrests = dictionary["arrests"] as? Int
                        var alerts = dictionary["alerts"] as? Int
                        var threats = dictionary["threats"] as? Int
                        var intoxicated = dictionary["intoxicated"] as? Int
                        var weapons = dictionary["weapons"] as? Int
                        
                        
                        
                        
                        
                        // fill out view with info from database
                        stops = stops + 1
                        if self.warningBtn.isSelected == true {
                            warnings = warnings + 1
                        }
                        if self.warningBtn.isSelected == true {
                            warnings = warnings + 1
                        }
                        if self.citationBtn.isSelected == true {
                            citations = citations + 1
                        }
                        if self.arrestedBtn.isSelected == true {
                            arrests = arrests! + 1
                        }
                        if self.alertBtn.isSelected == true {
                            alerts = alerts! + 1
                        }
                        if self.threatBtn.isSelected == true {
                            threats = threats! + 1
                        }
                        if self.intoxicatedBtn.isSelected == true {
                            intoxicated = intoxicated! + 1
                        }
                        if self.weaponBtn.isSelected == true {
                            weapons = weapons! + 1
                        }
                        
                        var ref: FIRDatabaseReference!
                        ref = FIRDatabase.database().reference()
                    
                        // send new values to firebase
                        let post = ["stops": stops,
                                    "warnings": warnings,
                                    "citations": citations,
                                    "arrests": arrests,
                                    "alerts": alerts,
                                    "threats": threats,
                                    "intoxicated": intoxicated,
                                    "weapons": weapons] as [String : Any]
                        let childUpdates = ["/citizen/"+citizenIDforFeedback+"/info": post]
                        ref.updateChildValues(childUpdates)
                        
                    }
                })
//            }
//        })

//        }
    }
    
}
