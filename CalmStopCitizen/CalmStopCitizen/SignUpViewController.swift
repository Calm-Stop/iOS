//
//  SignUpViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 4/12/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var licenseInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var birthdateInput: UITextField!
    @IBOutlet weak var zipCodeInput: UITextField!
    @IBOutlet weak var genderInput: UITextField!
    @IBOutlet weak var languageInput: UITextField!
    @IBOutlet weak var ethnicityInput: UITextField!
    
    // MARK: Data for drop-down options
    var genderPickerData = ["---", "Male", "Female", "Prefer not to answer"]
    var languagePickerData = ["---", "English", "Spanish", "Arabic", "Chinese (Mandarin)", "French", "German", "Italian", "Portuguese", "Russian", "Spanish", "Swedish", "Vietnamese" ]
    var ethnicityPickerData = ["---", "African American", "American Indian", "Asian", "Hispanic", "Pacific Islander", "White", "Two or more races", "Other ethnicity", "Prefer not to answer" ]
    
    // MARK: Text field delegates
    let phoneNumberDelegate = phoneNumberTextFieldDelegate()
    let zipCodeDelegate = zipCodeTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Tag each text field so they can be iterated through with "Next" button
        firstNameInput.delegate = self
        firstNameInput.tag = 0
        lastNameInput.delegate = self
        lastNameInput.tag = 1
        emailInput.delegate = self
        emailInput.tag = 2
        passwordInput.delegate = self
        passwordInput.tag = 3
        licenseInput.delegate = self
        licenseInput.tag = 4
        phoneNumberInput.delegate = phoneNumberDelegate
        phoneNumberInput.tag = 5
        birthdateInput.delegate = self
        birthdateInput.tag = 6
        zipCodeInput.delegate = zipCodeDelegate
        zipCodeInput.tag = 7
        genderInput.delegate = self
        genderInput.tag = 8
        languageInput.delegate = self
        languageInput.tag = 9
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Set up toolbar for datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SignUpViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        //let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/2, height: self.view.frame.size.height))
        //label.font = UIFont(name: "Helvetica", size: 12)
        //label.backgroundColor = UIColor.clear
        //label.textColor = UIColor.white
        //label.text = "Select your date of birth"
        //label.textAlignment = NSTextAlignment.center
        //let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,flexSpace,okBarBtn], animated: true)
        birthdateInput.inputAccessoryView = toolBar
        
        
        // Create gender pickerView
        let genderPickerView = UIPickerView()
        genderPickerView.delegate = self
        genderPickerView.tag = 1
        genderInput.inputView = genderPickerView
        genderInput.inputAccessoryView = toolBar
        
        // Create language pickerView
        let languagePickerView = UIPickerView()
        languagePickerView.delegate = self
        languagePickerView.tag = 2
        languageInput.inputView = languagePickerView
        languageInput.inputAccessoryView = toolBar

        // Create ethnicity pickerView
        let ethnicityPickerView = UIPickerView()
        ethnicityPickerView.delegate = self
        ethnicityPickerView.tag = 3
        ethnicityInput.inputView = ethnicityPickerView
        ethnicityInput.inputAccessoryView = toolBar

        }
    
    
    // Implement functionality for "Next" and "Go" buttons on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else if (textField.returnKeyType == UIReturnKeyType.go) {
            
            //loginButtonTapped(nil)
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
        birthdateInput.resignFirstResponder()
        genderInput.resignFirstResponder()
        languageInput.resignFirstResponder()
        ethnicityInput.resignFirstResponder()
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
        
        datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged),for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdateInput.text = dateFormatter.string(from: sender.date)
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
        if pickerView.tag == 1 {genderInput.text = genderPickerData[row]}
        else if pickerView.tag == 2 {languageInput.text = languagePickerData[row]}
        else if pickerView.tag == 3 {ethnicityInput.text = ethnicityPickerData[row]}
    }

    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let emailTxt = emailInput.text, let passwordTxt = passwordInput.text, let firstNameTxt = firstNameInput.text, let lastNameTxt = lastNameInput.text, let licenseTxt = licenseInput.text, let phoneTxt = phoneNumberInput.text, let birthdateTxt = birthdateInput.text, let zipCodeTxt = zipCodeInput.text, var genderTxt = genderInput.text, let languageTxt = languageInput.text, let ethnicityTxt = ethnicityInput.text else { return }
        
        

        FIRAuth.auth()?.createUser(withEmail: emailTxt, password: passwordTxt, completion: {(user: FIRUser?, error) in
            
            if error != nil {
                print (error ?? "Error Registering")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully authenticate user
            let ref = FIRDatabase.database().reference(fromURL: "https://calm-stop.firebaseio.com/")
            let usersReference = ref.child("citizen").child(uid).child("profile")
            let values = ["first_name": firstNameTxt, "last_name": lastNameTxt, "email": emailTxt, "ethnicity": ethnicityTxt, "phone_number": phoneTxt, "zipcode": zipCodeTxt, "language": languageTxt, "dob": birthdateTxt, "gender": genderTxt, "license_number": licenseTxt] as [String : Any] as [String : Any]
            usersReference.updateChildValues(values, withCompletionBlock: { (err,ref) in
                if err != nil{
                    
                    print(err ?? "Error")
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
                print("Saved user successfully into Firebase DB")
            })
            
        })
    }
    
}

