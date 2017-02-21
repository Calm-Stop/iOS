//
//  AccountViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/17/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBAction func logOut(_ sender: UIButton) {
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print (logoutError)
        }
        
        backToInitialView()
    }
    
    private func backToInitialView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "initialScreenVC") as! UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
