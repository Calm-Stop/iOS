//
//  SignInViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 3/20/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any?) {
        if let email = self.emailInput.text, let password = self.passwordInput.text {
            // [START headless_email_auth]
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                // [START_EXCLUDE]
                
                if let error = error {
                    print(error.localizedDescription)
                    //show alert
                    return
                }
                //self.navigationController!.popViewController(animated: true)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)

                
                // [END_EXCLUDE]
            }
            // [END headless_email_auth]
        } else {
            print("email/password can't be empty")
            //show alert
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
            
            if let user = user {
                let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "home") as! UIViewController
                self.present(vc2, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Tag each text field so they can be iterated through with "Next" button
        emailInput.delegate = self
        emailInput.tag = 0 //Increment accordingly
        passwordInput.delegate = self
        passwordInput.tag = 1
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Implement functionality for "Next" and "Go" buttons on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else if (textField.returnKeyType == UIReturnKeyType.go) {
            
            loginButtonTapped(nil)
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


}

