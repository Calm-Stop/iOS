//
//  WelcomeViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/16/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var requestInformation: UIButton!
    
    @IBAction func locateDriver(_ sender: UIButton) {
        
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.perform(#selector(WelcomeViewController.hideActivityIndicator), with: nil, afterDelay: 3.0)
    }
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        requestInformation.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        requestInformation.isHidden = true
        // Do any additional setup after loading the view.
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let name = dictionary["name"] as? String
                    self.welcomeLabel.text = "Welcome back, officer " + name! + "!"
                }
                
                print (snapshot)
            })
        }
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
