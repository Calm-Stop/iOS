//
//  HomeViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/27/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import Firebase
import UIKit

class HomeViewController: UIViewController {

    @IBAction func signOutTapped(_ sender: Any) {
        do{
            try FIRAuth.auth()?.signOut()
            
            var alert = UIAlertView()
            alert.delegate = self
            alert.title = "Logout"
            alert.message = "You've been Logged Out!"
            alert.addButton(withTitle: "OK")
            alert.show()
            
        }catch let logoutError{
            print (logoutError)
        }
        
        backToInitialView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        }
        
    private func backToInitialView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "initialScreenVC") 
        self.present(vc, animated: true, completion: nil)
    }


}
