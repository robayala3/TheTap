//
//  RegisterViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/1/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var m_txtFirstName: UITextField!
    @IBOutlet weak var m_txtLastName: UITextField!
    @IBOutlet weak var m_txtEmail: UITextField!
    @IBOutlet weak var m_txtPassword: UITextField!
    @IBOutlet weak var m_processAnimate: UIActivityIndicatorView!
    
    @IBOutlet weak var m_imgAvatar: UIImageView!
    
    var m_bAvatarChoosed : Bool = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        m_processAnimate.stopAnimating()
        
        m_txtFirstName.delegate = self
        m_txtLastName.delegate = self
        m_txtEmail.delegate = self
        m_txtPassword.delegate = self
        
        m_imgAvatar.layer.cornerRadius = 10
        m_imgAvatar.layer.borderColor = UIColor.redColor().CGColor
        m_imgAvatar.layer.borderWidth = 3
        m_imgAvatar.clipsToBounds = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = 0
        
        if m_txtEmail.editing || m_txtPassword.editing {
            self.view.frame.origin.y -= 50
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if m_txtEmail.editing || m_txtPassword.editing {
            self.view.frame.origin.y += 50
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        m_processAnimate.stopAnimating()
        m_txtFirstName.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionChoose(sender: AnyObject) {
        
        let imageController = UIImagePickerController()
        imageController.allowsEditing = true
        imageController.delegate = self
        
        let actionSheet = UIAlertController(title: "Where do you want to choose your image?", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let libButton = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (alert) -> Void in
            imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imageController, animated: true, completion: nil)
        }
        
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Take Photo")
                imageController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imageController, animated: true, completion: nil)
                
            }
            actionSheet.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed")
        }
        
        actionSheet.addAction(libButton)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //m_imgAvatar.contentMode = .ScaleAspectFit
            m_imgAvatar.image = pickedImage            
            m_bAvatarChoosed = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionDone(sender: AnyObject) {
        
        if m_txtFirstName.text!.isEmpty {
            showAlert("Please enter your first name")
            m_txtFirstName.becomeFirstResponder()
            return
        } else if m_txtLastName.text!.isEmpty {
            showAlert("Please enter your last name")
            m_txtLastName.becomeFirstResponder()
            return
        } else if m_txtEmail.text!.isEmpty {
            showAlert("Please enter your email address")
            m_txtEmail.becomeFirstResponder()
            return
        } else if m_txtPassword.text!.isEmpty {
            showAlert("Please enter your password")
            m_txtPassword.becomeFirstResponder()
            return
        } /*else if m_txtPassword.text!.utf16.count < 8 {
            showAlert("Password must be at least 8 characters")
            m_txtPassword.becomeFirstResponder()
            return
        }*/ else if m_bAvatarChoosed == false {
            showAlert("Please choose your avatar")
            return
        }
        
        m_processAnimate.startAnimating()
        
        let user = PFUser()
        
        user.username = m_txtEmail.text
        user.email = m_txtEmail.text
        user.password = m_txtPassword.text
        
        user["firstname"] = m_txtFirstName.text
        user["lastname"] = m_txtLastName.text
        user["isNew"] = true
        user["loggedInFB"] = false
        
        let imageData = UIImageJPEGRepresentation(m_imgAvatar.image!, 0.9)
        if imageData != nil {
            let profileFileObject = PFFile(data:imageData!)
            user.setObject(profileFileObject!, forKey: "avatar")
        }
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                self.m_processAnimate.stopAnimating()
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
                
                // Show the errorString somewhere and let the user try again.
                if error.code == 202 || error.code == 203 {                  // duplicated username
                    self.showAlert("Email has been already taken")
                    self.m_txtEmail.becomeFirstResponder()
                } else if error.code == 125 {
                    self.showAlert("Invalid email address")
                    self.m_txtEmail.becomeFirstResponder()
                }
                
            } else {
                // Hooray! Let them use the app now.
                PFUser.logOut()
                
                let tapInfo = PFObject(className:"TapInfo")
                tapInfo["userEmail"] = self.m_txtEmail.text
                tapInfo["fullname"] = self.m_txtFirstName.text! + " " + self.m_txtLastName.text!
                tapInfo["byFacebook"] = false
                tapInfo["taps"] = 0
                tapInfo["entries"] = 0
                tapInfo["earnedMoney"] = 0
                tapInfo["wins"] = 0
                tapInfo["isWinner"] = false
                tapInfo["redeemed"] = false
                tapInfo["winDate"] = 0
                tapInfo["keycode"] = self.randomStringWithLength(5)
                
                tapInfo.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.m_processAnimate.stopAnimating()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        // There was a problem, check error.description
                    }
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)        
        
        return true
    }
    
    func randomStringWithLength(len: Int) -> NSString {
        let letters: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: NSMutableString = NSMutableString(capacity: len)
        
        var flag: Bool = true
        
        while (flag == true) {
            randomString = NSMutableString(capacity: len)
            for (var i=0; i < len; i++) {
                let length = UInt32(letters.length)
                let rand = arc4random_uniform(length)
                randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
            }
            
            flag = false
            let query = PFUser.query()!
            query.whereKey("keycode", equalTo: randomString)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                flag = true
            }
        }
        
        
        return randomString
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "TAP.", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}