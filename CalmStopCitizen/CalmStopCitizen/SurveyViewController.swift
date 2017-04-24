//
//  SurveyViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 4/24/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
// import Firebase

class SurveyViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var verySatisfiedButton: UIButton!
    @IBOutlet weak var somewhatSatisfiedButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var somewhatDissatisfiedButton: UIButton!
    @IBOutlet weak var veryDissatisfiedButton: UIButton!
    @IBOutlet weak var noOpinionButton: UIButton!
    @IBOutlet weak var submitFeedbackButton: UIButton!
    
    
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
}
