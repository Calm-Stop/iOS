//
//  SurveyViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 4/24/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class SurveyViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var verySatisfiedButton: UIButton!
    @IBOutlet weak var somewhatSatisfiedButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var somewhatDissatisfiedButton: UIButton!
    @IBOutlet weak var veryDissatisfiedButton: UIButton!
    @IBOutlet weak var noOpinionButton: UIButton!
    @IBOutlet weak var submitFeedbackButton: UIButton!
    @IBOutlet weak var officerImageView: UIImageView!
    @IBOutlet weak var officerNameLabel: UILabel!
    @IBOutlet weak var badgeNumberLabel: UILabel!
    @IBOutlet weak var deptNumberLabel: UILabel!
    @IBOutlet weak var ratingMessage: UILabel!
    
    var oldOfficerRating: Float!
    var numberOfRatings: Int!
    var newOfficerRating: Float!
    var noOpinionCount: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        beaconIDString = ""
        print("beaconIDString = \(beaconIDString)")
        
        submitFeedbackButton.isEnabled = false
        officerImageView.layer.cornerRadius = self.officerImageView.frame.width/2
        officerImageView.clipsToBounds = true
        
        ratingMessage.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        ratingMessage.numberOfLines = 0
        checkIfUserIsLoggedIn()

        }

    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            let stopId = stopIDString
            var officerUid = "id"
            var officerDept = "dept"
            
            FIRDatabase.database().reference().child("stops").child(stopId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    officerUid = (dictionary["officerID"] as? String)!
                    //Check for id
                    FIRDatabase.database().reference().child("officer").child("14567").child(officerUid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let first_name = (dictionary["first_name"] as? String)!
                            let last_name = (dictionary["last_name"] as? String)!
                            let badge_number = (dictionary["badge_number"] as? String)!
                            let photoRef = dictionary["photo"] as? String
                            
                            
                            // fill out view with info from database
                            self.officerNameLabel.text = "Officer " + first_name + " " + last_name
                            self.badgeNumberLabel.text = "Badge #" + badge_number
                            self.deptNumberLabel.text = "Dept #" + officerDept
                            self.ratingMessage.text = "Please rate your encounter with Officer " + last_name + ":"
                            
                            //download image from firebase
                            let storage = FIRStorage.storage().reference()
                            let officerPhoto = storage.child(photoRef!)
                            officerPhoto.data(withMaxSize: 1*1000*1000) { (data, error) in
                                if error == nil {
                                    self.officerImageView.image = UIImage(data: data!)
                                }
                                else {
                                    print(error?.localizedDescription)
                                }
                            }
                        }
                        
                        print (snapshot)
                    })
                }
                print (snapshot)
            })
            
            print("got officer info")
        }
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // uncheck any other button that may be selected
        verySatisfiedButton.isSelected = false
        somewhatSatisfiedButton.isSelected = false
        neutralButton.isSelected = false
        somewhatDissatisfiedButton.isSelected = false
        veryDissatisfiedButton.isSelected = false
        noOpinionButton.isSelected = false
        
        // enable submitFeedback button
        submitFeedbackButton.isEnabled = true
        
        // change state of button that was tapped to selected
        sender.isSelected = true
    }
    
    
    
    @IBAction func submitFeedbackTapped(_ sender: UIButton) {
        
        // set officer rating on a 1-5 scale (very satisfied = 5, somewhat satisfied = 4, neutral = 3, somewhat dissatisfied = 2, very dissatisfied = 1, no opinion = 0)
        var officerRating: Int!
        
        if verySatisfiedButton.isSelected {
            officerRating = 5
        } else if somewhatSatisfiedButton.isSelected {
            officerRating = 4
        } else if neutralButton.isSelected {
            officerRating = 3
        } else if somewhatDissatisfiedButton.isSelected {
            officerRating = 2
        } else if veryDissatisfiedButton.isSelected {
            officerRating = 1
        } else if noOpinionButton.isSelected {
            officerRating = 0
        }
        
        let beaconId = beaconIDString
        var officerUid = "id"
        var officerDept = "dept"
        FIRDatabase.database().reference().child("beacons").child(beaconId).child("officer").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                officerUid = (dictionary["uid"] as? String)!
                officerDept = ( dictionary["department"] as? String)!
                
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        // get officer rating information from firebase
        FIRDatabase.database().reference().child("officer").child(officerDept).child(officerUid).child("ratings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.oldOfficerRating = dictionary["average_rating"] as? Float
                self.numberOfRatings = dictionary["number_of_ratings"] as? Int
                self.noOpinionCount = dictionary["no_opinion_count"] as? Int
            }
            
            if officerRating > 0 {
                // calculate new rating for officer if rating > 0
                let floatNumberOfRatings = Float(self.numberOfRatings)
                let floatOfficerRating = Float(officerRating)
                self.newOfficerRating = ((self.oldOfficerRating * floatNumberOfRatings) + floatOfficerRating ) / (floatNumberOfRatings + 1)
                self.numberOfRatings = self.numberOfRatings + 1
            } else if officerRating == 0 {
                self.noOpinionCount = self.noOpinionCount + 1
                self.newOfficerRating = self.oldOfficerRating
            }
            
            print (self.oldOfficerRating)
            print (self.numberOfRatings)
            print (self.noOpinionCount)
            print (self.newOfficerRating)

            // send new values to firebase
            let post = ["average_rating": self.newOfficerRating,
                        "number_of_ratings": self.numberOfRatings, "no_opinion_count": self.noOpinionCount] as [String : Any]
            let childUpdates = ["/officer/"+officerDept+"/"+officerUid+"/ratings": post]
            ref.updateChildValues(childUpdates)

            
        })
            }})
        
        

    }
    
}


