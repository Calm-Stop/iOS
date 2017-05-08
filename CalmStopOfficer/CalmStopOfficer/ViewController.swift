//
//  ViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/16/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        // default
        email.text = "a@b.com"
        password.text = "123456"
        
        guard let emailtxt = email.text, let passwordtxt = password.text

            else {
                print("Form is not valid")
                return
        }
        
        FIRAuth.auth()?.signIn(withEmail: emailtxt, password: passwordtxt, completion: { (user, error) in
            if error != nil{
                print(error ?? "Error loging in")
                return
            }
            // successfully logged in
            print("Successfully logged in!")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            //self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkIfUserIsLoggedIn()
        
        email.delegate = self
        email.tag = 0
        email.attributedPlaceholder = NSAttributedString(string:"Email",
                                                             attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        
        password.delegate = self
        password.tag = 1
        password.attributedPlaceholder = NSAttributedString(string:"Password",
                                                         attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
        
            if let user = user {
                let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "VC2") as! UITabBarController
                self.present(vc2, animated: true, completion: nil)
            }
        }
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            performSegue(withIdentifier: "loginSegue", sender: nil)
            print("Logged IN!!")
        }
    }


}

