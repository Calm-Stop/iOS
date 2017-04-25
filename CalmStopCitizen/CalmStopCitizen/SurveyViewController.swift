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
    
    let officerUID = "Tl4pCcIjlxTXQgCcoLp4IB4Hzti2"
    let officerDeptNo = "14567"
    var oldOfficerRating: Float!
    var numberOfRatings: Int!
    var newOfficerRating: Float!
    var noOpinionCount: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        submitFeedbackButton.isEnabled = false
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
        
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        // get officer rating information from firebase
        FIRDatabase.database().reference().child("officer").child("14567").child("Tl4pCcIjlxTXQgCcoLp4IB4Hzti2").child("ratings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.oldOfficerRating = dictionary["avg_rating"] as? Float
                self.numberOfRatings = dictionary["number_of_ratings"] as? Int
                self.noOpinionCount = dictionary["no_opinion_count"] as? Int
                print (self.oldOfficerRating)
                print (self.numberOfRatings)
                print (self.noOpinionCount)
            }
            
            if officerRating > 0 {
                // calculate new rating for officer if rating > 0
                let floatNumberOfRatings = Float(self.numberOfRatings)
                let floatOfficerRating = Float(officerRating)
                self.newOfficerRating = ((self.oldOfficerRating * floatNumberOfRatings) + floatOfficerRating ) / (floatNumberOfRatings + 1)
                self.numberOfRatings = self.numberOfRatings + 1
                print (self.newOfficerRating)
            } else if officerRating == 0 {
                self.noOpinionCount = self.noOpinionCount + 1
            }
            
            // send new values to firebase
            let post = ["avg_rating": self.newOfficerRating,
                        "number_of_ratings": self.numberOfRatings, "no_opinion_count": self.noOpinionCount] as [String : Any]
            let childUpdates = ["/officer/14567/Tl4pCcIjlxTXQgCcoLp4IB4Hzti2/ratings": post]
            ref.updateChildValues(childUpdates)

            
        })
        
        

    }
    
}


