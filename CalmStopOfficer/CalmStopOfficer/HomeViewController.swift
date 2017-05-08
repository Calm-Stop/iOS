//
//  HomeViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/2/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import CoreBluetooth

class HomeViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var wecomeLabel: UILabel!
    @IBOutlet weak var beaconNotRegisteredLabel: UILabel!
    
    var myBTManager: CBPeripheralManager?
    var isBluetoothOn: Bool = false

    
    // Initialize the beacon and region.
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")! as UUID, identifier: "CalmStop")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize bluetooth.
         myBTManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        //Check for beacon registered
        if (isBluetoothOn == true) {
//            checkForRegisteredBeacon()
        }
        else{
         // TODO: Print message telling user to turn bluetooth on.
        }
        
    }
    
    // Check if bluetooth is ON.
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
        if peripheral.state == CBManagerState.poweredOn {
            print("Broadcasting...")
            checkForRegisteredBeacon()
        } else if peripheral.state == CBManagerState.poweredOff {
            print("Stopped")
            createAlert(title: "Bluetooth is off!", message: "Please turn bluetooth on before using the app.")
            myBTManager!.stopAdvertising()
        } else if peripheral.state == CBManagerState.unsupported {
            print("Unsupported")
        } else if peripheral.state == CBManagerState.unauthorized {
            print("This option is not allowed by your application")
        }
    }
    
    
    // Check if officer has registered beacon
    func checkForRegisteredBeacon() -> Bool{
        
        var beaconRegistered = false
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("beacon_id"){
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let beaconId = (dictionary["beacon_id"] as? String)!
                    //TODO: Display beaconID.
                    self.beaconNotRegisteredLabel.text = "Beacon ID: " + beaconId
                    beaconRegistered = true
                }
            }
            else{
                //TODO: Display "Beacon not registered."
                self.beaconNotRegisteredLabel.text = "Beacon not Registered."

            }
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let first_name = (dictionary["first_name"] as? String)!
                self.wecomeLabel.text = "Welcome Back, officer " + first_name + "!"
            }
            
        })
        
        
        return beaconRegistered
    }
    
    // Alert if bluetooth is off
    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Ok button
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
