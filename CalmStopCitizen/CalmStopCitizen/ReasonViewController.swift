//
//  ReasonViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/29/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class ReasonViewController: UIViewController {

    @IBOutlet weak var reasonInput: UITextView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var driverGenderAge: UILabel!
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var citizenImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconIDString = "65535"
        citizenImage.layer.cornerRadius = self.citizenImage.frame.width/2
        citizenImage.clipsToBounds = true

        checkIfUserIsLoggedIn()
    }
    
    

    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let beaconId = beaconIDString
            var citizenUid = "id"
            FIRDatabase.database().reference().child("beacons").child(beaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let citizenUid = (dictionary["uid"] as? String)!

                FIRDatabase.database().reference().child("citizen").child(citizenUid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let first_name = dictionary["first_name"] as? String
                        let last_name = dictionary["last_name"] as? String
                        let zipcode = dictionary["zipcode"] as? String
                        let gender = dictionary["gender"] as? String
                       let photoRef = dictionary["photo"] as? String
                        
                        
                        self.driverName.text = first_name! + " " + last_name! 
                        self.zipCode.text = zipcode ?? ""
                        self.driverGenderAge.text = gender ?? ""
                        
                        //download image from firebase
                        let storage = FIRStorage.storage().reference()
                        let driverPhoto = storage.child(photoRef!)
                        driverPhoto.data(withMaxSize: 1*1000*1000) { (data, error) in
                            if error == nil {
                                self.citizenImage.image = UIImage(data: data!)
                            }
                            else {
                                print(error?.localizedDescription)
                            }
                        }
                    }
                    
                    print (snapshot)
                })
            }
    })
        }}
        

    @IBAction func submitReason(_ sender: UIButton) {
        let beaconId = beaconIDString
        FIRDatabase.database().reference().child("beacons").child(beaconId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let stop_id = (dictionary["stop_id"] as? String)!
                
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                
                
                // send new values to firebase
                ref.child("stops/"+stop_id+"/reason").setValue(self.reasonInput.text)
            }
        })
    }
    
}
