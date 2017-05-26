//
// InsuranceExtension.swift 
// CalmStopCitizen
//
//  Created by Annisa Karaca on 5/11/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension DocumentsViewController {
    // Functions for uploading insurance, saving insurance to core data, loading insurance from core data
    func saveInsuranceImage(image: UIImage) {
        
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
            NSEntityDescription.entity(forEntityName: "Insurance",
                                       in: managedContext)!
        
        let newImage = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        // 3
        newImage.setValue(imageData, forKey: "insuranceImage")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
        
    @IBAction func uploadInsurance(_ sender: Any) {
        print ("touched Upload!")
        imageUploaded = "insurance"
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
            popover!.present(from: uploadInsuranceBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    @IBAction func deleteInsurance(_ sender: Any) {
        print("delete button pressed!")
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Insurance")

        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
        
        loadInsurance()
    }
    
    @IBAction func viewInsurance(_ sender: Any) {
        photo = viewInsuranceBtn.backgroundImage(for: .normal)
        performSegue(withIdentifier: "popUpSegue", sender: self)
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
                            self.viewInsuranceBtn.setBackgroundImage(image, for: .normal)
                        }
                    }
                }
                
            } else {
                print("Profile : No data found")
                self.viewInsuranceBtn.setBackgroundImage(nil, for: .normal)
            }
        } catch {
            
            print ("Error Loading")
        }
    }

}

