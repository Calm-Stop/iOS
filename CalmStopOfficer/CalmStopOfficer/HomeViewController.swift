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
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var wecomeLabel: UILabel!
    @IBOutlet weak var beaconNotRegisteredLabel: UILabel!
    
    @IBOutlet weak var pressBeaconLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var myBTManager: CBPeripheralManager?
    var isBluetoothOn: Bool = false
    var myBeaconId = ""
    var active = false
    var citizenID = ""
    
    // Initialize the beacon and region.
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")! as UUID, identifier: "CalmStop")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notSearching()
        //Initialize bluetooth.
         myBTManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        // Beacon Stuff
        locationManager.delegate = self
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            locationManager.requestWhenInUseAuthorization()
        }
        
//        locationManager.startRangingBeacons(in: region)
//        locationManager.stopMonitoring(for: region)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: Date())
        print(dateString)   // "4:44 PM on June 23, 2016\n"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkForRegisteredBeacon()
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
    
    
    // Check if officer has registered beacon in the database
    func checkForRegisteredBeacon() -> Bool{
        
        var beaconRegistered = false
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("beacon_id"){
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let beaconId = (dictionary["beacon_id"] as? String)!
                    self.myBeaconId = beaconId
                    // Display beacon ID
                    self.beaconNotRegisteredLabel.text = "Beacon ID: " + beaconId
                    beaconRegistered = true
                    self.locationManager.startRangingBeacons(in: self.region)
                }
            }
            else{
                // Display that beacon is not registered
                self.beaconNotRegisteredLabel.text = "Beacon not Registered."

            }
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let first_name = (dictionary["first_name"] as? String)!
                let photoPath = (dictionary["photo"] as? String)!

                self.wecomeLabel.text = "Welcome Back, officer " + first_name + "!"
                self.downloadProfileImage(path: photoPath)
                print(photoPath)
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
    
    
    // Search for beacons
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // Checks for beacons in range
        let knowBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knowBeacons.count > 0 && !(checkIfActive())){
            print("ENTROU AQUI")
            setActive(active: true)
            searching()
            initiateStop(beacons: beacons)
        }
        
        if (knowBeacons.count <= 0){
            setActive(active: false)
            notSearching()
        }
    }
    
    
    // Initiates the stop. Checks if officer is beacon id is the same that the officer is using.
    // checks if there is a citizen associated with beacon.
    func initiateStop(beacons: [CLBeacon]){
        print("IS ACTIVE")

        if (checkIfActive()){
            checkIfOfficerBeaconIsTheSameAsBeaconBeingPressed(beacons: beacons){ (result) -> () in
                if result{
                    print("Found Beacon")
                    self.checkForCitizenAssociatedWithBeacon { (result) -> () in
                        if result{
                            print("Found USER")
                            //                            self.setActive(active: false)
                            self.notSearching()
                            self.generateStopId {(result) -> () in
                                if result{
                                    // Go to next view controller
                                    self.performSegue(withIdentifier: "goToInitialResponseSegue", sender: nil)
                                }
                            }
                        }
                        else{
                            //TODO: Print Message "No User could be found!"
                            print("No User could be found!")
                        }
                    }
                }
            }
        }
    }
    
    
    
    // Checks if officer is using the same beacon that he/she have registered in the database
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
                    let alert = UIAlertController(title: "Error", message: "Beacon not Found or Officer not registered in the same beacon!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    self.notSearching()
                }
            }
        })
    }
    
    
    // Checks if any user responded to the beacon stop, if yes, connects to that user.
    func checkForCitizenAssociatedWithBeacon(completion: @escaping (_ result: Bool) -> ()) {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            
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
            })
        }
    }
    
    
    // Checks if the beacon is active on the firebase.
    func checkIfActive() -> Bool{
        FIRDatabase.database().reference().child("beacons").child(myBeaconId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.active = (dictionary["isInStop"] as? Bool)!
            }
        })
     
        return active
    }
    
    // Makes the beacon active during the stop
    func setActive(active: Bool){
        self.active = true
        let uid = FIRAuth.auth()?.currentUser?.uid
        let beaconRef = FIRDatabase.database().reference().child("beacons").child(myBeaconId)
        let beaconValues = ["isInStop": active] as [String : Any]
        
        beaconRef.updateChildValues(beaconValues) { (error, ref) in
            if  error != nil {
                print(error ?? "")
                return
            }
        }
    }
    
    
    // Generates the stop id with all fields:
    // StopID, Date, time, longitude, latitude, officerID, citizen ID, reason, and threadID
    func generateStopId(completion: @escaping (_ result: Bool) -> ()){
        print("GENERATE STOPID CALLED")
        //Grab information I need
        
        // Date
        let date = getDate()
        
        // Time
        let time = getTime()
        
        // Latitude
        let lat = String(getLocation().coordinate.latitude)
        
        // Longitude
        let long = String(getLocation().coordinate.longitude)
        
        //Generate StopID

        //citizenID
        FIRDatabase.database().reference().child("beacons").child(myBeaconId).child("citizen").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.citizenID = (dictionary["uid"] as? String)!
                
                //Create Child StopID under "Stops" with all fields filled
                let uid = FIRAuth.auth()?.currentUser?.uid
                var ref = FIRDatabase.database().reference().child("stops")
                let childRef = ref.childByAutoId()
                
                var values = ["citizenID": self.citizenID, "date":date, "lat":lat, "long": long, "officerID":uid!, "reason": "", "time": time, "threadID": childRef.key] as [String : Any]
                
                childRef.updateChildValues(values) { (error, ref) in
                    if  error != nil {
                        print(error ?? "")
                        return
                    }
                    completion(true)
                    
                }
                
                
                //Add StopID under "beacons"
                ref = FIRDatabase.database().reference().child("beacons").child(self.myBeaconId)
                values = ["stop_id": childRef.key, ] as [String : Any]
                
                ref.updateChildValues(values) { (error, ref) in
                    if  error != nil {
                        print(error ?? "")
                        return
                    }
                }
                
                //Add stopID to citizen
                ref = FIRDatabase.database().reference().child("citizen").child(self.citizenID).child("stops").child(childRef.key)
                values = ["stop_id": childRef.key, ] as [String : Any]
                
                ref.updateChildValues(values) { (error, ref) in
                    if  error != nil {
                        print(error ?? "")
                        return
                    }
                }
                
                
                //Add StopID to officer
                ref = FIRDatabase.database().reference().child("officer").child("14567").child(uid!).child("stops").child(childRef.key)
                values = ["stop_id": childRef.key, ] as [String : Any]
                
                ref.updateChildValues(values) { (error, ref) in
                    if  error != nil {
                        print(error ?? "")
                        return
                    }
                }
            }
        })
    }
    
    
    // Searching for drivers when beacon is activated
    func searching(){
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        pressBeaconLabel.text = "Locating driver..."
    }
    
    // TODO: Define when to stop searching!!
    // Stop searching
    func notSearching(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        pressBeaconLabel.text = "After making a stop, turn on beacon to locate driver..."
    }
    
    // Gets current date
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    
    // Get current time
    func getTime() ->String{
        let date = Date()
//        let calendar = Calendar.current
//        
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
////        let timeoftheday = calendar.component(., from: <#T##Date#>)
//        return("\(hour):\(minutes):\(seconds)")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: date)
        return dateString   // "4:44PM"
    }
    
    
    func getLocation() -> CLLocation {
        return locationManager.location!
    }
    
    func downloadProfileImage(path: String){
        let storage = FIRStorage.storage().reference()
        let profile = storage.child(path)
        
        
        // Download Images
        profile.data(withMaxSize: 1*1000*10000) { (data, error) in
            if error == nil {
                self.profileImage.image = UIImage(data: data!)
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.clipsToBounds = true
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
}
