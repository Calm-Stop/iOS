//
//  EditProfileViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/28/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var zipcodeField: UITextField!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var birthdateField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var ethnicityField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    // MARK: Actions
    @IBAction func updateProfileBtn(_ sender: Any) {
        updateProfile()
    }
    
    @IBAction func imageBtnPressed(_ sender: Any) {
        chooseProfileImage()
    }
    
    @IBAction func changeButtonPressed(_ sender: Any) {
        chooseProfileImage()
    }
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        downloadProfileImage()
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
                    let zipcode = dictionary["zipcode"] as? String
                    let language = dictionary["language"] as? String
                    let birthdate = dictionary["dob"] as? String
                    let gender = dictionary["gender"] as? String
                    let ethnicity = dictionary["ethnicity"] as? String

                    
                    self.firstNameField.text = first_name ?? ""
                    self.lastNameField.text = last_name  ?? ""
                    self.phoneNumberField.text = phone_number ?? ""
                    self.zipcodeField.text = zipcode ?? ""
                    self.languageField.text = language ?? ""
                    self.birthdateField.text = birthdate ?? ""
                    self.genderField.text = gender ?? ""
                    self.ethnicityField.text = ethnicity ?? ""
                }
                
                print (snapshot)
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
            //uploadProfileImage(image: image)
        }
        else{
            // TODO: Error
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func downloadProfileImage(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child("images/profile/"+uid!)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.profileImageView.image = UIImage(data: data!)
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
                self.profileImageView.clipsToBounds = true
                
                
                
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func uploadProfileImage(image: UIImage){
        // Upload
        
        let imgData: NSData = NSData(data: UIImagePNGRepresentation(image)!)
        var imageSize: Int = imgData.length
        
        if imageSize > 1000000 {
            var resizedImage = resizeImageWith(image: image, newWidth: image.size.width/CGFloat(2))
            uploadProfileImage(image: resizedImage)
        }
        
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
                print(error)
            }
            
        }
    }
    
    func resizeImageWith(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let floatNewWidth = Float(newWidth)
        let floatOldWidth = Float(image.size.width)
        let scale = floatNewWidth/floatOldWidth
        let newHeight = image.size.height * CGFloat(scale)
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!

    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    func updateProfile(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        if profileImageView.image != nil {
            print("uploading profile image")
            uploadProfileImage(image: profileImageView.image!)
        }
        
        FIRDatabase.database().reference().child("citizen").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Update profile
            let ref = FIRDatabase.database().reference().child("citizen").child(uid!).child("profile")
            let first_name = self.firstNameField.text ?? ""
            let last_name = self.lastNameField.text ?? ""
            let phone_number = self.phoneNumberField.text ?? ""
            let zipcode = self.zipcodeField.text ?? ""
            let language = self.languageField.text ?? ""
            let dob = self.birthdateField.text ?? ""
            let gender = self.genderField.text ?? ""
            let ethnicity = self.ethnicityField.text ?? ""
            
            let imagePath = "images/profile/"+uid!
            
            let values = ["first_name": first_name, "last_name": last_name, "phone_number": phone_number, "zipcode": zipcode, "language": language, "dob": dob, "gender": gender, "ethnicity": ethnicity, "photo": imagePath]
            
            
            ref.updateChildValues(values) { (error, ref) in
                if  error != nil {
                    print(error ?? "")
                    return
                }
            }
            
        })
    }
    
    
    func chooseProfileImage() {
        print("choosing profile image")
        
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
    


    }




