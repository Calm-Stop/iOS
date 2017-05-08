//
//  WelcomeViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/16/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class WelcomeViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")! as UUID, identifier: "CalmStop")

    // "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    
    var checked = 1
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var requestInformation: UIButton!
    
    @IBOutlet weak var locatingLabel: UILabel!
    
    @IBAction func locateDriver(_ sender: UIButton) {
        
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        locatingLabel.isHidden = false
        activityIndicator.startAnimating()
        
        self.perform(#selector(WelcomeViewController.hideActivityIndicator), with: nil, afterDelay: 8.0)
    }
    
    @IBAction func manageBeaconButton(_ sender: UIButton) {
        stopAnimating()
    }
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
//        requestInformation.isHidden = false
//        locatingLabel.text = "Stopalog phones were detected! Click the button for more information..."
        performSegue(withIdentifier: "goToInitialResponseSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        locatingLabel.isHidden = true
        // Do any additional setup after loading the view.
        
        // Beacon
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        
        checkIfUserIsLoggedInAndBeaconIsRegistered()
    }
    
    func checkIfUserIsLoggedInAndBeaconIsRegistered(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let name = dictionary["first_name"] as? String
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    
        let knowBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knowBeacons.count > 0) && (checked == 0){
            
            
            if (checked == 0){
                startAnimating()
                
                checkIfOfficerBeaconIsTheSameAsBeaconBeingPressed(beacons: beacons){ (result) -> () in
                    if result{
                        self.checkForCitizenAssociatedWithBeacon { (result) -> () in
                            if result{
                                self.perform(#selector(WelcomeViewController.hideActivityIndicator), with: nil, afterDelay: 1.0)
                            }
                        }
                    }
                }
                
//                checked = 1
            }
        }
        
        if (knowBeacons.count <= 0){
            checked = 0
            stopAnimating()
        }
    }
    
    
    private func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLBeaconRegion) {
        print("Entered region!!")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        checked = 0
    }
    
    
    func checkForCitizenAssociatedWithBeacon(completion: @escaping (_ result: Bool) -> ()) {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
//            let beaconId = "0xaaaa0000002f"
//            var beaconId = "116"
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let beaconId = (dictionary["beacon_id"] as? String)!
                    
                    FIRDatabase.database().reference().child("beacons").child(beaconId).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild("citizen"){
                            completion(true)
                            print("Tem sim!")
                        }
                        
                    })
                }
                print(snapshot)
            })
        }
    }
    
    func checkIfOfficerBeaconIsTheSameAsBeaconBeingPressed(beacons: [CLBeacon], completion: @escaping (_ result: Bool) -> ()) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let beaconId = (dictionary["beacon_id"] as? String)!
                
                let knowBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
                if (knowBeacons.count > 0) && (knowBeacons[0].major.stringValue == beaconId){
                    
                FIRDatabase.database().reference().child("beacons").child(beaconId).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild("officer"){
                            completion(true)
                            print("Officer ta Registrado!")
                        }
                        
                    })

                }
                else {
                    let alert = UIAlertController(title: "Error", message: "Beacon not found or officer not registered in the same beacon!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    self.stopAnimating()
                }
                
            }
            print(snapshot)
        })

    }

    override func viewDidDisappear(_ animated: Bool) {
//        locatingLabel.text = "Turn Beacon off and start the process again!"
        stopAnimating()
        locationManager.stopMonitoring(for: region)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopAnimating()
        locationManager.stopMonitoring(for: region)
    }
    
    
    func startAnimating(){
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        locatingLabel.isHidden = false
        locatingLabel.text = "Locating CalmStop phones within 100 ft:"
        activityIndicator.startAnimating()
        checked = 1
    }

    func stopAnimating(){
        locatingLabel.text = "Turn Beacon off and start the process again!"
        activityIndicator.isHidden = true
        locatingLabel.isHidden = true
        
    }

}
