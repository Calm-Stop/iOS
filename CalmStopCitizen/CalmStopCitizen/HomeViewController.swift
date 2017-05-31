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

    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    
    
    var timer = Timer()
    
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
        checkIfUserIsLoggedIn()
        timerWithInterval()
    }
    
    
        
    private func backToInitialView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "initialScreenVC") 
        self.present(vc, animated: true, completion: nil)
    }
    
    func timerWithInterval(){
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBeaconID), userInfo: nil, repeats: true)
        print("looking for beacon")
        print("BeaconID: ", beaconIDString)
    }
    
    func updateBeaconID(){
        
        if (beaconIDString != "" && beaconIDString != "No Beacons") {
            timer.invalidate()
            self.performSegue(withIdentifier: "initialContactSegue", sender: nil)
            print("Entered here")
        }
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
                    
                    let profileImagePath = dictionary["photo"] as? String
                    
                    self.downloadProfileImage(path: profileImagePath!)
                    
                    
                    self.nameLabel.text = first_name! + " " + last_name!
                    
                }
                
                print (snapshot)
            })
        }
    }
    
    func downloadProfileImage(path: String){
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let profile = storage.child(path)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.driverImage.image = UIImage(data: data!)
                self.driverImage.layer.cornerRadius = self.driverImage.frame.size.width/2
                self.driverImage.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }

}
