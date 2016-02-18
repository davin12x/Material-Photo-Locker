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
    @IBOutlet weak var pressMe: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var fingerprintLabel: UILabel!
    @IBOutlet weak var emailAddress:UITextField!
    var smtpSession = MCOSMTPSession()
    
    private var password:String{
        _password = MykeychainWrapper.myObjectForKey("v_Data") as? String
        return _password
    }
    
    let MykeychainWrapper = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
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
    @IBAction func onForgetPressed(){
        
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
        builder.htmlBody = "Your Password for Photo Lock is \(password)"
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperationWithData(rfc822Data)
        sendOperation.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
            } else {
                NSLog("Successfully sent email!")
            }
        }
//        let email = MFMailComposeViewController()
//        email.mailComposeDelegate = self
//        email.setSubject("Lost Password")
//        email.setMessageBody("This is test", isHTML: false)
//        presentViewController(email, animated: true, completion: nil)
    
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
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
    func checkLogin(password:String)->Bool{
        if password == MykeychainWrapper.myObjectForKey("v_Data") as? String{
            passwordField.placeholder = ""
            return true
        }
        else{
            passwordField.placeholder = "Wrong Password"
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

