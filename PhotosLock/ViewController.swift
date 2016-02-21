//
//  ViewController.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-06.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import LocalAuthentication
import MessageUI


class ViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    private var _password:String!
    var context = LAContext()
    var WrongPassCount = 0
    @IBOutlet weak var pressMe: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var fingerprintLabel: UILabel!
    @IBOutlet weak var emailAddress:UITextField!
    var smtpSession = MCOSMTPSession()
    
    
    let MykeychainWrapper = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        touchId()
        let hasLogin = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if hasLogin {
            passwordField.placeholder = "Enter Your Password"
            confirmPasswordField.hidden = true
            pressMe.hidden = true
            emailAddress.hidden = true
        }else{
            passwordField.placeholder = "Create Your Password"
            confirmPasswordField.placeholder = "Confirm Password"
            
            pressMe.hidden = false
        }
        
    }
    func getEmail()->String{
        let email = NSUserDefaults.standardUserDefaults().valueForKey("email")
        return email as! String
    }
   
    @IBAction func onButtonPressed(sender: AnyObject) {
        if passwordField.text! == "" {
            let alertView = UIAlertController(title: "Login Problem",
                message: "Wrong password." as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
        else if passwordField.placeholder == "Create Your Password"{
            if passwordField.text == confirmPasswordField.text{
                MykeychainWrapper.mySetObject(passwordField.text, forKey: kSecValueData)
                MykeychainWrapper.writeToKeychain()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
                NSUserDefaults.standardUserDefaults().setValue(emailAddress.text, forKey: "email")
                NSUserDefaults.standardUserDefaults().synchronize()
                performSegueWithIdentifier("login", sender: self)
            }
            else{
                view.makeToast(message: "Confirm password do not match")
                passwordField.text = ""
                confirmPasswordField.text = ""
            }
        }
        else if checkLogin(passwordField.text!){
            passwordField.placeholder = ""
            performSegueWithIdentifier("login", sender: nil)
        }
        passwordField.text = ""
        
    }
    func checkHint(hint:String)->Bool{
        if hint == MykeychainWrapper.myObjectForKey("v_Data") as? String{
            return true
        }
        else{
            return false
        }
    }
    private var orignalPassword:String{
        _password = MykeychainWrapper.myObjectForKey("v_Data") as? String
        print(_password)
        return _password
    }
    func checkLogin(password:String)->Bool{
        if password == MykeychainWrapper.myObjectForKey("v_Data") as? String{
            passwordField.placeholder = ""
            return true
        }
        else{
            ++WrongPassCount
            if WrongPassCount == 5{
                smtpSession.hostname = "smtp.gmail.com"
                smtpSession.username = "davin12x@gmail.com"
                smtpSession.password = "ygzrgoedscmeinvu"
                smtpSession.port = 465
                smtpSession.authType = MCOAuthType.SASLPlain
                smtpSession.connectionType = MCOConnectionType.TLS
                smtpSession.connectionLogger = {(connectionID, type, data) in
                    if data != nil {
                        if let string = NSString(data: data, encoding: NSUTF8StringEncoding){
                            NSLog("Connectionlogger: \(string)")
                        }
                    }
                }
                let builder = MCOMessageBuilder()
                builder.header.to = [MCOAddress(displayName: "Photo Lock User", mailbox: getEmail())]
                builder.header.from = MCOAddress(displayName: "Photo Lock", mailbox: getEmail())
                builder.header.subject = "Password Recovery"
                builder.htmlBody = "Your Password for Photo Lock is \(orignalPassword)"
                let rfc822Data = builder.data()
                self.WrongPassCount = 0
                let sendOperation = smtpSession.sendOperationWithData(rfc822Data)
                sendOperation.start { (error) -> Void in
                    if (error != nil) {
                        NSLog("Error sending email: \(error)")
                        let alert = UIAlertController(title: "Password send failed", message: "Check Your Internet Connection", preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        NSLog("Successfully sent email!")
                        
                        let alert = UIAlertController(title: "Successfull", message: "Password sent to your email", preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                }
            }
            passwordField.placeholder = "Wrong Password"
            return false
            
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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

