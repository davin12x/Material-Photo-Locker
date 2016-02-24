//
//  Settings.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-23.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import WYMaterialButton

class Settings: UIViewController {
    
    @IBOutlet weak var save:WYMaterialButton!
    
    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var confirmPassField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func onEmailPressed(sender:AnyObject){
         emailTextField.hidden = false
    
    }
    @IBAction func onPasswordPressed(sender:AnyObject){
        confirmPassField.hidden = false
        passwordField.hidden = false
    }
    
    
    @IBAction func onSavePressed(sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.hidden = true
        confirmPassField.hidden = true
        passwordField.hidden = true

    }


}
