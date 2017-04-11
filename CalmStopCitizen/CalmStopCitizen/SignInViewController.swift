//
//  SignInViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 3/20/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

