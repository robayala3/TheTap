//
//  LoginViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/1/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var m_txtEmail: UITextField!
    @IBOutlet weak var m_txtPassword: UITextField!
    @IBOutlet weak var m_processAnimate: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         m_processAnimate.stopAnimating()
        
        m_txtEmail.delegate = self
        m_txtPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        m_processAnimate.stopAnimating()
        self.m_txtEmail.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionResetPassword(sender: AnyObject) {
        if m_txtEmail.text!.isEmpty {
            self.showAlert("Please enter your email address")
            self.m_txtEmail.becomeFirstResponder()
            
            return
        }
        
        PFUser.requestPasswordResetForEmailInBackground(m_txtEmail.text!)
        
        self.showAlert("The email to reset your password was sent")
    }
    
    @IBAction func actionCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionLogin(sender: AnyObject) {
        m_processAnimate.startAnimating()
        
        PFUser.logInWithUsernameInBackground(m_txtEmail.text!, password:m_txtPassword.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.m_processAnimate.stopAnimating()
                
//                if PFUser.currentUser()?.objectForKey("emailVerified")?.boolValue == false {
//                    self.showAlert("Please verify your email address")
//                    PFUser.logOut()
//                    return
//                }                
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                // The login failed. Check error to see why.
                self.m_processAnimate.stopAnimating()                
                
                self.showAlert("Wrong email or password")
                self.m_txtEmail.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)        
        
        return true
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "TAP.", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}