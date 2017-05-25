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

var photo: UIImage?

class DocumentsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate {
    
    // insurance outlets
    @IBOutlet weak var viewInsuranceBtn: UIButton!
    @IBOutlet weak var viewInsurance: UIImageView!
    @IBOutlet weak var uploadInsuranceBtn: UIButton!
    
    // registration outlets
    @IBOutlet weak var registrationImageView: UIImageView!
    @IBOutlet weak var uploadRegistrationBtn: UIButton!
    
    // license outlets
    @IBOutlet weak var licenseImageView: UIImageView!
    @IBOutlet weak var uploadLicenseBtn: UIButton!
    
    var imageUploaded: String!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadInsurance()
        loadRegistration()
        uploadRegistrationBtn.isEnabled = true

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
        // Set photoImageView to display the selected image and save selectedImage to Core data.
        switch imageUploaded{
        case "insurance":
            viewInsurance.image = selectedImage
            saveInsuranceImage(image: selectedImage)
        case "registration" :
            registrationImageView.image = selectedImage
            saveRegistrationImage(image: selectedImage)
        case "license" :
            licenseImageView.image = selectedImage
            saveLicenseImage(image: selectedImage)
        default:
            dismiss(animated: true, completion: nil)
        }
        
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
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
            
            switch imageUploaded{
            case "insurance": popover!.present(from: uploadInsuranceBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            case "registration": popover!.present(from: uploadRegistrationBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            case "license": popover!.present(from: uploadLicenseBtn.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            default:
                dismiss(animated: true, completion: nil)
            }

        }
    }

    
    
   }
