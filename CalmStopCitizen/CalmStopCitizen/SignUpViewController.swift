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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var birthdateInput: UITextField!
    // @IBOutlet weak var datePicker: UIDatePicker!
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //birthdateInput.inputView = datePicker
        
        
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
    
    @IBAction func birthdateEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged),for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdateInput.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let emailTxt = emailInput.text, let passwordTxt = passwordInput.text, let firstNameTxt = firstNameInput.text, let lastNameTxt = lastNameInput.text else { return }
        
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
            let values = ["first_name": firstNameTxt, "last_name": lastNameTxt, "email": emailTxt]
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

