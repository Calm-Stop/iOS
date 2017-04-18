//
//  SignUpViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/16/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate  {
    @IBOutlet weak var departmentId: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func returnToLoginBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerBtn(_ sender: UIButton) {
        guard let emailtxt = email.text, let passssordtxt = password.text, let departmenttxt = departmentId.text, let nametxt = name.text else { return }
        
        FIRAuth.auth()?.createUser(withEmail: emailtxt, password: passssordtxt, completion: {(user: FIRUser?, error) in
            
            if error != nil {
                print (error ?? "Error Registering")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully authenticate user
            let ref = FIRDatabase.database().reference(fromURL: "https://calm-stop.firebaseio.com/")
            
            // TODO: Check for officer department and then insert the officer into the database
            let usersReference = ref.child("officer").child("14567").child(uid)
            let values = ["first_name": nametxt, "email": emailtxt, "departmentID": departmenttxt]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        departmentId.delegate = self
        departmentId.tag = 0
        departmentId.attributedPlaceholder = NSAttributedString(string:"Department ID #", attributes:[NSForegroundColorAttributeName: UIColor.white])

        name.delegate = self
        name.tag = 1
        name.attributedPlaceholder = NSAttributedString(string:"Name", attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        email.delegate = self
        email.tag = 2
        email.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        password.delegate = self
        password.tag = 3
        password.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
