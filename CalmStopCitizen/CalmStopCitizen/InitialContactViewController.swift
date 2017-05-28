//
//  InitialContactViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/16/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class InitialContactViewController: UIViewController {
    
    
    
    // MARK: Outlets
    @IBOutlet weak var officerNameLabel: UILabel!
    @IBOutlet weak var badgeNumberLabel: UILabel!
    @IBOutlet weak var deptNumberLabel: UILabel!
    @IBOutlet weak var requestText: UITextView!
    @IBOutlet weak var officerImageView: UIImageView!
    
    // Document variables
    var insuranceImage: UIImage!
    var registrationImage: UIImage!
    var licenseImage: UIImage!

    // Stop_id
    // var stop_id: String!
    
    // Officer variables
    var officerUID: String!
    var officerDept: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Get a reference to the storage service using the default Firebase App
        beaconIDString = "65535"
        officerImageView.layer.cornerRadius = self.officerImageView.frame.width/2
        officerImageView.clipsToBounds = true
        checkIfUserIsLoggedIn()
        updateCitizenChild()
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Not logged in!")
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            let beaconId = beaconIDString
            var officerUid = "id"
            var officerDept = "dept"
            print("BeaconID: ", beaconId)
            
            FIRDatabase.database().reference().child("beacons").child(beaconId).child("officer").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    officerUid = (dictionary["uid"] as? String)!
                    officerDept = ( dictionary["department"] as? String)!
                    //Check for id
                    FIRDatabase.database().reference().child("officer").child(officerDept).child(officerUid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let first_name = (dictionary["first_name"] as? String)!
                            let last_name = (dictionary["last_name"] as? String)!
                            let badge_number = (dictionary["badge_number"] as? String)!
                            let photoRef = dictionary["photo"] as? String

                            
                            // fill out view with info from database
                            self.officerNameLabel.text = "Officer " + first_name + " " + last_name
                            self.badgeNumberLabel.text = "Badge #" + badge_number
                            self.deptNumberLabel.text = "Dept #" + officerDept
                            self.requestText.text = "Officer " + last_name + " has made a traffic stop and is requesting the license, insurance, and vehicle registration from the driver."
                            
                            //download image from firebase
                            let storage = FIRStorage.storage().reference()
                            let officerPhoto = storage.child(photoRef!)
                            officerPhoto.data(withMaxSize: 1*1000*1000) { (data, error) in
                                if error == nil {
                                    self.officerImageView.image = UIImage(data: data!)
                                }
                                else {
                                    print(error?.localizedDescription)
                                }
                            }
                        }
                        
                        print (snapshot)
                    })
                }
                print (snapshot)
            })
            
            print("got officer info")
        }
    }
    

    
    func updateCitizenChild() {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        let uid = FIRAuth.auth()?.currentUser?.uid

        // send new values to firebase
        let post = ["uid": uid] as [String : Any]
        let childUpdates = ["/beacons/"+beaconIDString+"/citizen": post]
        ref.updateChildValues(childUpdates)
        
    }
    
    func loadOfficerUid() -> String {
        var id = String()
        // load officer Id using beacon id
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).child("officer").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                // print(dictionary)
                id = (dictionary["uid"] as? String)!
            }
        })
        print(id)
        return(id)
    }
    
    func loadOfficerDept() -> String {
        var dept = String()
        // load officer Id using beacon id
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).child("officer").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                // print(dictionary)
                dept = (dictionary["department"] as? String)!
            }
        })
        print(dept)
        return(dept)
    }
    
    func loadOfficerInfo(uid: String, deptNumber: String) {
        print(uid)
        print(deptNumber)
        
        // load officer info from officer uid
        
        FIRDatabase.database().reference().child("officer").child(self.officerDept).child(self.officerUID).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                print(dictionary)
                let firstName = dictionary["first_name"] as? String
                let lastName = dictionary["last_name"] as? String
                let badgeNumber = dictionary["badge"] as? String
                let deptNumber = dictionary["department"] as? String
                let photoRef = dictionary["photo"] as? String
                
                
                self.officerNameLabel.text = "Officer " + firstName! + " " + lastName!
                self.badgeNumberLabel.text = "Badge #" + badgeNumber!
                self.deptNumberLabel.text = "Dept #" + deptNumber!
                self.requestText.text = "Officer " + lastName! + " has made a traffic stop and is requesting the license, insurance, and vehicle registration from the driver."
                
                //download image from firebase
                let storage = FIRStorage.storage().reference()
                let officerPhoto = storage.child(photoRef!)
                officerPhoto.data(withMaxSize: 1*1000*1000) { (data, error) in
                    if error == nil {
                        self.officerImageView.image = UIImage(data: data!)
                        // self.insuranceButton.setBackgroundImage(self.insurancePhoto, for: .normal)
                    }
                    else {
                        print(error?.localizedDescription)
                    }
                }
            }
            
        })

    }
    
    @IBAction func sendDocuments(_ sender: UIButton) {
        loadInsurance()
        uploadInsurance()
        loadRegistration()
        uploadRegistration()
        loadLicense()
        uploadLicense()
        updateImagePaths()
    }
    
    func loadInsurance() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Insurance")
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                print("Insurance Image found!")
                
                for result in results as! [NSManagedObject] {
                    
                    if let imageData = result.value(forKey: "insuranceImage") as? NSData {
                        if let image = UIImage(data: imageData as Data) {
                            insuranceImage = image
                        }
                    }
                }
                
            } else {
                print("Profile : No data found")
                insuranceImage = nil
            }
        } catch {
            
            print ("Error Loading")
        }
    }
    
    func uploadInsurance() {
        // Upload
        
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let stop_id = (dictionary["stop_id"] as? String)!
                print(stop_id)
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                
                let storage = FIRStorage.storage().reference()
                
                let tempImageRef = storage.child(stop_id+"/insurance")
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/png"
                
                tempImageRef.put(UIImagePNGRepresentation(self.insuranceImage)!, metadata: metaData) { (data, error) in
                    if error == nil {
                        print("Upload successful")
                    }
                    else{
                        print(error)
                    }
                    
                }

            }
        })
        
            }
    
    func loadRegistration() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Registration")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                print("Registration Image found!")
                
                for result in results as! [NSManagedObject] {
                    
                    if let imageData = result.value(forKey: "registrationImage") as? NSData {
                        if let image = UIImage(data: imageData as Data) {
                            registrationImage = image
                        }
                    }
                }
                
            } else {
                print("Profile : No data found")
                registrationImage = nil
            }
        } catch {
            
            print ("Error Loading")
        }

    }
    
    func uploadRegistration() {
        // Upload
        
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let stop_id = (dictionary["stop_id"] as? String)!
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                
                let storage = FIRStorage.storage().reference()
                
                let tempImageRef = storage.child(stop_id+"/registration")
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/png"
                
                tempImageRef.put(UIImagePNGRepresentation(self.registrationImage)!, metadata: metaData) { (data, error) in
                    if error == nil {
                        print("Upload successful")
                    }
                    else{
                        print(error)
                    }
                    
                }
                
            }
        })
        
    }
    
    func loadLicense() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "License")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                print("License Image found!")
                
                for result in results as! [NSManagedObject] {
                    
                    if let imageData = result.value(forKey: "licenseImage") as? NSData {
                        if let image = UIImage(data: imageData as Data) {
                            licenseImage = image
                        }
                    }
                }
                
            } else {
                print("Profile : No data found")
                licenseImage = nil
            }
        } catch {
            
            print ("Error Loading")
        }
    }
    
    func uploadLicense() {
        // Upload
        
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let stop_id = (dictionary["stop_id"] as? String)!
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                
                let storage = FIRStorage.storage().reference()
                
                let tempImageRef = storage.child(stop_id+"/license")
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/png"
                
                tempImageRef.put(UIImagePNGRepresentation(self.licenseImage)!, metadata: metaData) { (data, error) in
                    if error == nil {
                        print("Upload successful")
                    }
                    else{
                        print(error)
                    }
                    
                }
                
            }
        })
        
    }
        
    func updateImagePaths(){
        FIRDatabase.database().reference().child("beacons").child(beaconIDString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let stop_id = (dictionary["stop_id"] as? String)!
                let uid = FIRAuth.auth()?.currentUser?.uid
        
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                FIRDatabase.database().reference().child("beacons").child(beaconIDString).child("citizen").child("documents").observeSingleEvent(of: .value, with: { (snapshot) in
            
                    // send new values to firebase
                    let post = ["insurance": stop_id+"/insurance",
                                "license": stop_id+"/license",
                                "registration": stop_id+"/registration"] as [String : Any]
                    let childUpdates = ["/beacons/"+beaconIDString+"/citizen/documents": post]
                    ref.updateChildValues(childUpdates)
            
            
        })
        
        print("paths updated!")
    }

        })
    }
    
    
}



