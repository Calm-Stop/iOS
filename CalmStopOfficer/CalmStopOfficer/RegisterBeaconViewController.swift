//
//  RegisterBeaconViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 5/1/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class RegisterBeaconViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var list = ["114", "115", "116"]
    
    var checked = 0
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")! as UUID, identifier: "CalmStop")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Beacon
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        //TODO: Get major value for beacon and pass it as an ID.
        

        
        let knowBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knowBeacons.count > 0) && (checked == 0){
            
            for beacon in beacons{
                list.append(beacon.major.stringValue)
            }
            
            // TODO: Display list of beacons to officer on a table view.
            
            // instead of [0] pass number of colum that user selected.
            //            let closestBeacon = knowBeacons[0] as CLBeacon
            //            print(closestBeacon)
            //            minorValueLabel.text =
            //            print(String(describing: closestBeacon.proximityUUID))
            checked = 1
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)!
        
        let beacon = currentCell.textLabel!.text!
        print(currentCell.textLabel!.text!)
        createAlert(title: "Is this the beacon you want?", beaconId: beacon)
        self.tableView.deselectRow(at: indexPath, animated: true)

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "beaconCell")
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
    func createAlert(title: String, beaconId: String){
        let alert = UIAlertController(title: title, message: beaconId, preferredStyle: .alert)
        let beaconAlert = UIAlertController(title: "Beacon Added Successfully!", message: "", preferredStyle: .alert)
        
        
        // OK button
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // TODO: Check if there is an officer associated with that beacon, 
            // if yes, ask if you're sure you want to remove, if no, just add the officer to that beacon.
            alert.dismiss(animated: true, completion: nil)
            
            //Register beacon if user clicks ok.
            if FIRAuth.auth()?.currentUser?.uid == nil {
                print("Not logged in!")
            } else {
                let uid = FIRAuth.auth()?.currentUser?.uid
                
                // Delete Officer from previous beacon
                FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let beaconId = (dictionary["beacon_id"] as? String)!
                        
                        // TODO: Delete the whole beacon child or just officer?
                        let deleteBeaconRef = FIRDatabase.database().reference().child("beacons").child(beaconId).child("officer")
                        deleteBeaconRef.removeValue()
                    }
               
                
                    //Register Beacon under Officer.
                    let ref = FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile")
                    let values = ["beacon_id": beaconId] as [String : Any]
                    
                    ref.updateChildValues(values) { (error, ref) in
                        if  error != nil {
                            print(error ?? "")
                            return
                        }
                    }
                    
                    //Register Officer under Beacons.
                    let beaconRef = FIRDatabase.database().reference().child("beacons").child(beaconId).child("officer")
                    let beaconValues = ["uid": uid!, "department": "14567"] as [String : Any]
                    
                    beaconRef.updateChildValues(beaconValues) { (error, ref) in
                        if  error != nil {
                            print(error ?? "")
                            return
                        }
                    }
                })
            }
            
            // Alert to say that beacon was added successfully
            beaconAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)

            }))
            
            self.present(beaconAlert, animated: true, completion: nil)

        }))
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
