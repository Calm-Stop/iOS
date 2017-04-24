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
        var oldOfficerRating: Float!
        var numberOfRatings: Int!
        var newOfficerRating: Float!
        
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
        
        // get officer rating information from firebase
        FIRDatabase.database().reference().child("officer").child("14567").child("Tl4pCcIjlxTXQgCcoLp4IB4Hzti2").child("ratings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                oldOfficerRating = dictionary["avg_rating"] as? Float
                numberOfRatings = dictionary["number_of_ratings"] as? Int
                print (oldOfficerRating)
                print (numberOfRatings)
                
                // calculate new rating for officer if rating > 0
                let floatNumberOfRatings = Float(numberOfRatings)
                let floatOfficerRating = Float(officerRating)
                newOfficerRating = ((oldOfficerRating * floatNumberOfRatings) + floatOfficerRating ) / (floatNumberOfRatings + 1)
                print (newOfficerRating)
            }
            
            
            
        })
        

        
    }
    
}
    

