//
//  commentsViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 4/24/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var commentsBox: UITextView!
    @IBOutlet weak var submitCommentsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        beaconIDString = "65535"
        submitCommentsButton.isEnabled = false
        commentsBox.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        commentsBox.text = ""
        submitCommentsButton.isEnabled = true
    }
    
    @IBAction func submitCommentsButtonTapped(_ sender: UIButton) {
        
        let beaconId = beaconIDString
        var officerUid = "id"
        var officerDept = "dept"
        FIRDatabase.database().reference().child("beacons").child(beaconId).child("officer").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                officerUid = (dictionary["uid"] as? String)!
                officerDept = ( dictionary["department"] as? String)!
                
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
        
                let key = ref.child("officer").child("14567").child("Tl4pCcIjlxTXQgCcoLp4IB4Hzti2").child("comments").childByAutoId().key
        
                // send new values to firebase
                let post = ["text": self.commentsBox.text] as [String : Any]
                let childUpdates = ["/officer/"+officerDept+"/"+officerUid+"/comments/\(key)": post]
                ref.updateChildValues(childUpdates)
            }
        })

        commentsBox.isEditable = false
        submitCommentsButton.isEnabled = false
    }
    
    @IBAction func submitComplaintButtonTapped(){
        UIApplication.shared.openURL(URL(string: "http://www.cityofsantacruz.com/departments/police/how-do-i/obtain-a-citizen-comment-form")!)
    }
    


}
