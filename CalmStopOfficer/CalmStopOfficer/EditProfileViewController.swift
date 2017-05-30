//
//  EditProfileViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/8/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
    
    @IBAction func importImage(_ sender: UIButton) {
        
        let image = UIImagePickerController()
        image.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                image.sourceType = UIImagePickerControllerSourceType.camera
                self.present(image, animated: true)
            }else{
                print("Camera not available!")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(image, animated: true){
                //TODO: After it is complete
            }
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
//        image.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
            uploadProfileImage(image: image)
        }
        else{
            // TODO: Error
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
            
            let imagePath = "images/profile/"+uid!
            
            let values = ["first_name": first_name, "last_name": last_name, "email": email, "phone_number": phone_number, "gender": gender, "badge_number": badge_number, "photo": imagePath]

            
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
        let uid = FIRAuth.auth()?.currentUser?.uid

//        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child("images/profile/"+uid!)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.profileImage.image = UIImage(data: data!)
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.clipsToBounds = true
                
                
                
            }
            else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func uploadProfileImage(image: UIImage){
        // Upload
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let storage = FIRStorage.storage().reference()
        
        let tempImageRef = storage.child("images/profile/" + uid!)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/png"
        
        tempImageRef.put(UIImagePNGRepresentation(image)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("Upload successful")
            }
            else{
                print(error ?? "")
            }
            
        }
    }
    
}
