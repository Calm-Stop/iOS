//
//  ProfileViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/28/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ethnicityLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }

    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("citizen").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let first_name = dictionary["first_name"] as? String
                    let last_name = dictionary["last_name"] as? String
                    let phone_number = dictionary["phone_number"] as? String
                    let zip_code = dictionary["zipcode"] as? String
                    let language = dictionary["language"] as? String
                    let date_of_birth = dictionary["dob"] as? String
                    let gender = dictionary["gender"] as? String
                    let ethnicity = dictionary["ethnicity"] as? String

                    let profileImagePath = dictionary["photo"] as? String
                    
                    self.downloadProfileImage(path: profileImagePath!)
                    
                    
                    self.firstNameLabel.text = first_name
                    self.lastNameLabel.text = last_name
                    self.phoneNumberLabel.text = phone_number ?? " "
                    self.zipCodeLabel.text = zip_code ?? " "
                    self.languageLabel.text = language ?? " "
                    self.birthdateLabel.text = date_of_birth ?? " "
                    self.genderLabel.text = gender ?? " "
                    self.ethnicityLabel.text = ethnicity ?? " "

                }
                
                print (snapshot)
            })
        }
    }
    
    func downloadProfileImage(path: String){
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child(path)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.profilePictureImageView.image = UIImage(data: data!)
                self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2
                self.profilePictureImageView.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }

}
