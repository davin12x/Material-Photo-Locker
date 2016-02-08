//
//  ViewController.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-06.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import LocalAuthentication


class ViewController: UIViewController, UITextFieldDelegate {

   
    var context = LAContext()
    @IBOutlet weak var pressMe: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fingerprintLabel: UILabel!
    let MykeychainWrapper = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        touchId()
        let hasLogin = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if hasLogin {
            passwordField.placeholder = "Enter Your Password"
            pressMe.hidden = true
        }else{
            passwordField.placeholder = "Create Your Password"
            pressMe.hidden = false
        }
        
    }
    @IBAction func onButtonPressed(sender: AnyObject) {
        if passwordField.text! == "" {
            let alertView = UIAlertController(title: "Login Problem",
                message: "Wrong password." as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
        else if checkLogin(passwordField.text!){
            performSegueWithIdentifier("login", sender: nil)
        }
        else if passwordField.placeholder == "Create Your Password"{
            MykeychainWrapper.mySetObject(passwordField.text, forKey: kSecValueData)
            MykeychainWrapper.writeToKeychain()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
            NSUserDefaults.standardUserDefaults().synchronize()
            performSegueWithIdentifier("login", sender: self)
        }
        passwordField.text = ""
        passwordField.placeholder = "Wrong Password"
    }
    func checkLogin(password:String)->Bool{
        if password == MykeychainWrapper.myObjectForKey("v_Data") as? String{
            return true
        }
        else{
            return false
        }
    }
    func touchId(){
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:nil) {
            // 2.
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Scan your finger to sign in ",
                reply: { (success : Bool, error : NSError? ) -> Void in
                    
                    // 3.
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            self.performSegueWithIdentifier("login", sender: self)
                        }
                        
                        if error != nil {
                            
                            var message : NSString
                            var showAlert : Bool
                            
                            // 4.
                            switch(error!.code) {
                            case LAError.AuthenticationFailed.rawValue:
                                message = "There was a problem verifying your identity."
                                showAlert = true
                                break;
//                            case LAError.UserCancel.rawValue:
//                                message = "You pressed cancel."
//                                showAlert = true
//                                break;
                            case LAError.UserFallback.rawValue:
                                message = "You pressed password."
                                showAlert = false
                                break;
                            default:
                                showAlert = false
                                message = "Touch ID may not be configured"
                                break;
                            }
                            
                            let alertView = UIAlertController(title: "Error",
                                message: message as String, preferredStyle:.Alert)
                            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                            alertView.addAction(okAction)
                            if showAlert {
                                self.presentViewController(alertView, animated: true, completion: nil)
                            }
                            
                        }
                    })
                    
            })
        } else {
            fingerprintLabel.hidden = true
            let alertView = UIAlertController(title: "Error",
                message: "Touch ID not available on your Phone" as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
    }


    @IBAction func onTouchIdPressed(sender: AnyObject) {
        touchId()
    }

}

