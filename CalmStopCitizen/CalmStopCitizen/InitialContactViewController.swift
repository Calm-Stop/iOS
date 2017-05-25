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


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Get a reference to the storage service using the default Firebase App
        loadOfficerInfo()
    }
    
    func loadOfficerInfo() {
        // hard-coded officer ID
        let officerUID = "Tl4pCcIjlxTXQgCcoLp4IB4Hzti2"
        let officerDept = "14567"
    
        FIRDatabase.database().reference().child("officer").child(officerDept).child(officerUID).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
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
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let storage = FIRStorage.storage().reference()
        
        let tempImageRef = storage.child("images/documents/insurance/" + uid!)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/png"
        
        tempImageRef.put(UIImagePNGRepresentation(insuranceImage)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("Upload successful")
            }
            else{
                print(error)
            }
            
        }
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
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let storage = FIRStorage.storage().reference()
        
        let tempImageRef = storage.child("images/documents/registration/" + uid!)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/png"
        
        tempImageRef.put(UIImagePNGRepresentation(registrationImage)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("Upload successful")
            }
            else{
                print(error)
            }
            
        }
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
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let storage = FIRStorage.storage().reference()
        
        let tempImageRef = storage.child("images/documents/license/" + uid!)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/png"
        
        tempImageRef.put(UIImagePNGRepresentation(licenseImage)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("Upload successful")
            }
            else{
                print(error)
            }
            
        }
    }

    
}



