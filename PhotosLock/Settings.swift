//
//  Settings.swift
//  PhotosLock
//
//  Created by Lalit on 2016-02-23.
//  Copyright © 2016 Bagga. All rights reserved.
//

import UIKit
import WYMaterialButton
import AVFoundation
import iAd

class Settings: UIViewController,ADBannerViewDelegate {
    
    
    var sfxButton:AVAudioPlayer!
    var checkButton:Bool = true
    @IBOutlet var IADBanner: ADBannerView?
    @IBOutlet weak var save:WYMaterialButton!
    
    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var confirmPassField: UITextField!
    @IBOutlet var passwordField: UITextField!
    let MykeychainWrapper = KeychainWrapper()
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        IADBanner?.hidden = false
        
    }
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print(error)
    }
    @IBAction func onEmailPressed(sender:AnyObject){
        sfxButton.play()
        UIView.animateWithDuration(0.5, delay:0.1, usingSpringWithDamping:1, initialSpringVelocity: 0.1, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.emailTextField.hidden = false
            self.emailTextField.tag = 1
            }, completion: { (finished:Bool) -> Void in
                
        })
    }
    @IBAction func onPasswordPressed(sender:AnyObject){
        sfxButton.play()
        UIView.animateWithDuration(0.5, delay:0.1, usingSpringWithDamping:1, initialSpringVelocity: 0.1, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.confirmPassField.hidden = false
            self.passwordField.hidden = false
            self.passwordField.tag = 1
            }, completion: { (finished:Bool) -> Void in
                
        })
        
    }
    
    
    func matchPass(pass:String,cPass:String)->Bool{
        if pass == cPass  {
            
            checkButton = true
            return checkButton
        }
        passwordField.text = ""
        confirmPassField.text = ""
        view.makeToast(message: "Password do not match")
        checkButton = false
        return checkButton
    }
    @IBAction func onSavePressed(sender: AnyObject) {
        sfxButton.play()
        if (passwordField.text != "" || confirmPassField.text != "" || emailTextField.text != "") {
            let pass = passwordField.text
            let cPass = confirmPassField.text
            
            if passwordField.tag == 1 {
                matchPass(pass!,cPass: cPass!)
                MykeychainWrapper.mySetObject(passwordField.text, forKey: kSecValueData)
                MykeychainWrapper.writeToKeychain()
            }
            if emailTextField.tag == 1{
                NSUserDefaults.standardUserDefaults().setValue(emailTextField.text, forKey: "email")
            }
            if ((matchPass(pass!,cPass: cPass!) == true && passwordField.tag == 1) || (emailTextField.tag == 1 && matchPass(pass!,cPass: cPass!) == true) ){
                NSUserDefaults.standardUserDefaults().synchronize()
                UIView.animateWithDuration(0.5, delay:0.1, usingSpringWithDamping:1, initialSpringVelocity: 0.1, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.view.makeToast(message: "Saved Successfully")
                    
                    }, completion: { (finished:Bool) -> Void in
                      self.navigationController?.popViewControllerAnimated(true)  
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true 
        IADBanner?.delegate = self
        IADBanner?.hidden = true
        emailTextField.hidden = true
        confirmPassField.hidden = true
        passwordField.hidden = true
        do{
            try sfxButton = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "mp3")!))
            
        }catch let err as NSError{
            print (err)
        }
        sfxButton.prepareToPlay()

    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }


}
