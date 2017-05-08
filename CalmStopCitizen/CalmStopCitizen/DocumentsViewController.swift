//
//  DocumentsViewController.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 5/5/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class DocumentsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate {
    
    @IBOutlet weak var viewInsuranceBtn: UIButton!
    @IBOutlet weak var viewInsurance: UIImageView!
    @IBOutlet weak var uploadInsuranceBtn: UIButton!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadInsurance()
    }
    

    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Set photoImageView to display the selected image.
        viewInsurance.image = selectedImage
        
        // Save selectedImage to Core Data
        saveInsuranceImage(image: selectedImage)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
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
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.present(from: uploadInsuranceBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }



    @IBAction func deleteInsurance(_ sender: Any) {
    }
    
    @IBAction func viewInsrance(_ sender: Any) {
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
                            viewInsurance.image = image
                        }
                    }
                    
                    
                    
                }
                
                
            } else {
                print("Profile : No data found")
            }
            
            //print("Loaded!!!")
            
        } catch {
            
            print ("Error Loading")
        }
    }
}
