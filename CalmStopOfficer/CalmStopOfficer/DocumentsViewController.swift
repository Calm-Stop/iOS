//
//  DocumentsViewController.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 4/10/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit
import Firebase

var photo: UIImage?

class DocumentsViewController: UIViewController {


    @IBOutlet weak var insuranceButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var licenseButton: UIButton!
    
    private var insurancePhoto: UIImage?
    private var registrationPhoto: UIImage?
    private var driverLicensePhoto: UIImage?
    
    @IBAction func insuranceActionButton(_ sender: UIButton) {
        photo = self.insurancePhoto
        performSegue(withIdentifier: "popUpSegue", sender: self)
    }
    
    @IBAction func registrationActionButton(_ sender: UIButton) {
        photo = self.registrationPhoto
        performSegue(withIdentifier: "popUpSegue", sender: self)
    }
    
    @IBAction func driverLicenceActionButton(_ sender: UIButton) {
        photo = self.driverLicensePhoto
        performSegue(withIdentifier: "popUpSegue", sender: self)
    }
    
//    var tempImageRef = storage.child("images/profile/license.png")
//    var registration = storage.child("images/profile/registration.png")
//    var insurance = storage.child("images/profile/insurance.png")
    
    var licensePath = ""
    var registrationPath = ""
    var insurancePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getDocumentImagesPath{(result) -> () in
            if result{
                let storage = FIRStorage.storage().reference()
                
                let tempImageRef = storage.child(self.licensePath)
                let registration = storage.child(self.registrationPath)
                let insurance = storage.child(self.insurancePath)
                
                // Download Images
                insurance.data(withMaxSize: 1*1000*1000) { (data, error) in
                    if error == nil {
                        self.insurancePhoto = UIImage(data: data!)
                        self.insuranceButton.setBackgroundImage(self.insurancePhoto, for: .normal)
                    }
                    else {
                        print(error?.localizedDescription ?? "")
                    }
                }
                
                registration.data(withMaxSize: 1*1000*1000) { (data, error) in
                    if error == nil {
                        self.registrationPhoto = UIImage(data: data!)
                        //                self.registrationButton.setImage(image, for: .normal)
                        self.registrationButton.setBackgroundImage(self.registrationPhoto, for: .normal)
                    }
                    else {
                        print(error?.localizedDescription ?? "")
                    }
                }
                
                
                tempImageRef.data(withMaxSize: 1*1000*1000) { (data, error) in
                    if error == nil {
                        self.driverLicensePhoto = UIImage(data: data!)
                        self.licenseButton.setBackgroundImage(self.driverLicensePhoto, for: .normal)
                    }
                    else {
                        print(error?.localizedDescription ?? "")
                    }
                }

                
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDocumentImagesPath(completion: @escaping (_ result: Bool) -> ()){
        FIRDatabase.database().reference().child("beacons").child(generalBeaconID).child("citizen").child("documents").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                self.licensePath = (dictionary["drivers_license"] as? String) ?? ""
                self.registrationPath = (dictionary["insurance"] as? String) ?? ""
                self.insurancePath = (dictionary["registration"] as? String) ?? ""
                
                completion(true)
            }
        })
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
