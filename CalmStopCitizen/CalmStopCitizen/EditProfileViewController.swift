//
//  EditProfileViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/28/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

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
    
    // MARK: Data for drop-down options
    var genderPickerData = ["---", "Male", "Female", "Prefer not to answer"]
    var languagePickerData = ["---", "English", "Spanish", "Arabic", "Chinese (Mandarin)", "French", "German", "Italian", "Portuguese", "Russian", "Spanish", "Swedish", "Vietnamese" ]
    var ethnicityPickerData = ["---", "African American", "American Indian", "Asian", "Hispanic", "Pacific Islander", "White", "Two or more races", "Other ethnicity", "Prefer not to answer" ]
    
    // MARK: Text field delegates
    let phoneNumberDelegate = phoneNumberTextFieldDelegate()
    let zipCodeDelegate = zipCodeTextFieldDelegate()
    
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
        self.navigationController?.isNavigationBarHidden = true
        checkIfUserIsLoggedIn()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        downloadProfileImage()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Tag each text field so they can be iterated through with "Next" button
        firstNameField.delegate = self
        firstNameField.tag = 0
        lastNameField.delegate = self
        lastNameField.tag = 1
        phoneNumberField.delegate = phoneNumberDelegate
        phoneNumberField.tag = 5
        birthdateField.delegate = self
        birthdateField.tag = 6
        zipcodeField.delegate = zipCodeDelegate
        zipcodeField.tag = 7
        genderField.delegate = self
        genderField.tag = 8
        languageField.delegate = self
        languageField.tag = 9
        
        // Set up toolbar for datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EditProfileViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexSpace,flexSpace,okBarBtn], animated: true)
        birthdateField.inputAccessoryView = toolBar
        
        
        // Create gender pickerView
        let genderPickerView = UIPickerView()
        genderPickerView.delegate = self
        genderPickerView.tag = 1
        genderField.inputView = genderPickerView
        genderField.inputAccessoryView = toolBar
        
        // Create language pickerView
        let languagePickerView = UIPickerView()
        languagePickerView.delegate = self
        languagePickerView.tag = 2
        languageField.inputView = languagePickerView
        languageField.inputAccessoryView = toolBar
        
        // Create ethnicity pickerView
        let ethnicityPickerView = UIPickerView()
        ethnicityPickerView.delegate = self
        ethnicityPickerView.tag = 3
        ethnicityField.inputView = ethnicityPickerView
        ethnicityField.inputAccessoryView = toolBar

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                self.performSegue(withIdentifier: "finishedEditing", sender: nil)
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
    
    @IBAction func birthdateEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        
        // set minimum (16 years old) and maximum (100 years old) birthdates
        var components = DateComponents()
        components.year = -100
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        datePickerView.minimumDate = minDate
        
        components.year = -16
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePickerView.maximumDate = maxDate
        
        datePickerView.addTarget(self, action: #selector(EditProfileViewController.datePickerValueChanged),for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdateField.text = dateFormatter.string(from: sender.date)
    }
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        if pickerView.tag == 1 {return genderPickerData.count}
        else if pickerView.tag == 2 {return languagePickerData.count}
        else if pickerView.tag == 3 {return ethnicityPickerData.count}
        else {return 1}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {return genderPickerData[row]}
        else if pickerView.tag == 2 {return languagePickerData[row]}
        else if pickerView.tag == 3 {return ethnicityPickerData[row]}
        else {return ("Error")}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {genderField.text = genderPickerData[row]}
        else if pickerView.tag == 2 {languageField.text = languagePickerData[row]}
        else if pickerView.tag == 3 {ethnicityField.text = ethnicityPickerData[row]}
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
        birthdateField.resignFirstResponder()
        genderField.resignFirstResponder()
        languageField.resignFirstResponder()
        ethnicityField.resignFirstResponder()
    }
    
    


    }




