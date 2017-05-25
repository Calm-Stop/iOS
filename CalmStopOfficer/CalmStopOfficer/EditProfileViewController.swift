//
//  EditProfileViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/8/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var gender: UITextField!
    
    @IBOutlet weak var badgeNumber: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBAction func updateProfile(_ sender: UIButton) {
        updateProfile()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        downloadProfileImage()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
            FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let first_name = dictionary["first_name"] as? String
                    let last_name = dictionary["last_name"] as? String
                    let email = dictionary["email"] as? String
                    let phone_number = dictionary["phone_number"] as? String
                    let gender = dictionary["gender"] as? String
                    let badge_number = dictionary["badge_number"] as? String
                    
                    self.firstName.text = first_name ?? ""
                    self.lastName.text = last_name  ?? ""
                    self.email.text = email ?? ""
                    self.phoneNumber.text = phone_number ?? ""
                    self.gender.text = gender ?? ""
                    self.badgeNumber.text = badge_number ?? ""
                }
                
                print (snapshot)
            })
        }
    }
    
    func updateProfile(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Update profile
            let ref = FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile")
            let first_name = self.firstName.text
            let last_name = self.lastName.text
            let email = self.email.text
            let phone_number = self.phoneNumber.text
            let gender = self.gender.text
            let badge_number = self.badgeNumber.text
            
            let values = ["first_name": first_name, "last_name": last_name, "email": email, "phone_number": phone_number, "gender": gender, "badge_number": badge_number]

            
            ref.updateChildValues(values) { (error, ref) in
                if  error != nil {
                    print(error ?? "")
                    return
                }
            }
            
        })
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func downloadProfileImage(){
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child("images/profile/default_male")
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*1000) { (data, error) in
            if error == nil {
                self.profileImage.image = UIImage(data: data!)
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }

}
