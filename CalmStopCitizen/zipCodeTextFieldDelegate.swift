//
//  zipCodeTextFieldDelegate.swift
//  CalmStopCitizen
//
//  Created by Annisa Karaca on 4/20/17.
//  Copyright © 2017 Calm Stop. All rights reserved.
//

import Foundation
import UIKit

class zipCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        
        return newText.length <= 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
        
    }
    
}
