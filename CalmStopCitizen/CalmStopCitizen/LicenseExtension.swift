//
//  LicenseExtension.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/15/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//


import Foundation
import UIKit
import CoreData

extension DocumentsViewController {
    // Functions for uploading license, saving license to core data, loading license from core data
    func saveLicenseImage(image: UIImage) {
        
        let imageData =  UIImagePNGRepresentation(image) as NSData?
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "License",
                                       in: managedContext)!
        
        let newImage = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        // 3
        newImage.setValue(imageData, forKey: "licenseImage")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    @IBAction func uploadLicense(_ sender: Any) {
        print ("touched Upload!")
        imageUploaded = "license"
        print (imageUploaded)
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        //let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        //imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        //imagePickerController.delegate = self
        //present(imagePickerController, animated: true, completion: nil)
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            popover!.present(from: uploadLicenseBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    @IBAction func deleteLicense(_ sender: Any) {
        print("delete button pressed!")
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "License")
        
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
        
        loadLicense()
        
    }
    
    @IBAction func viewLicense(_ sender: Any) {
        photo = viewLicenseBtn.backgroundImage(for: .normal)
        performSegue(withIdentifier: "popUpSegue", sender: self)
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
                            self.viewLicenseBtn.setBackgroundImage(image, for: .normal)
                        }
                    }
                }
                
            } else {
                print("Profile : No data found")
                self.viewLicenseBtn.setBackgroundImage(nil, for: .normal)
            }
        } catch {
            
            print ("Error Loading")
        }
    }
    
}



