//
//  RespondedViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 3/14/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class RespondedViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    // Table fields
    @IBOutlet weak var stop: UILabel!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var citations: UILabel!
    @IBOutlet weak var arrests: UILabel!
    @IBOutlet weak var alerts: UILabel!
    @IBOutlet weak var threats: UILabel!
    @IBOutlet weak var intoxicated: UILabel!
    @IBOutlet weak var weapons: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Driver"
        checkIfUserIsLoggedIn()

        // Do any additional setup after loading the view.
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
            let beaconId = "116"
            var citizenuid = "id"
            
            FIRDatabase.database().reference().child("beacons").child(beaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    citizenuid = (dictionary["uid"] as? String)!
                    //Check for id
                    FIRDatabase.database().reference().child("citizen").child(citizenuid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let name = (dictionary["first_name"] as? String)!
                            let last_name = (dictionary["last_name"] as? String)!
//                            let gender = (dictionary["gender"] as? String)!
                            let gender = "Female"
                            let age = (dictionary["license_number"] as? String)!
//                            let language = (dictionary["language"] as? String)!
                            let language = "English"
//                            let state = (dictionary["address"] as? String)!
                            let state = "Washington"
                            
                            
                            self.nameLabel.text = name + " " + last_name
                            self.genderLabel.text = gender + " - " + age
                            self.languageLabel.text = language
                            self.stateLabel.text = state
                            
                            // Fill out table
                            FIRDatabase.database().reference().child("citizen").child(citizenuid).child("profile").child("info").observeSingleEvent(of: .value, with: { (snapshot) in
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
