//
//  RedeemViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/7/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class RedeemViewController: UIViewController {
    
    @IBOutlet weak var m_txtKeyCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionMenu(sender: AnyObject) {
        if revealViewController() != nil {
            revealViewController().revealToggle(sender)
        }
    }
    
    @IBAction func actionRedeem(sender: AnyObject) {
        if m_txtKeyCode.text!.isEmpty {
            showAlert("Please enter the code you were invited")
            return
        }
        
        let curUser = PFUser.currentUser()!
        let query = PFQuery(className:"TapInfo")
        query.whereKey("userEmail", equalTo: curUser.email!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                let keycode = object["keycode"] as! String
                if keycode.isEqual(self.m_txtKeyCode.text) {
                    self.showAlert("You can't redeem your code")
                    return
                } else if object.objectForKey("redeemed")?.boolValue == true {
                    self.showAlert("You have already redeemed")
                    return
                } else {
                    self.processRedeem()
                    self.showAlert("Successfully redeemed")
                    return
                }
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
            
        }
    }
    
    func processRedeem() {
        let curUser = PFUser.currentUser()!
        let query1 = PFQuery(className:"TapInfo")
        query1.whereKey("userEmail", equalTo: curUser.email!)
        query1.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                object["redeemed"] = true
                var entries = object["entries"] as! Int
                entries = entries + 100
                object["entries"] = entries
                object.saveInBackground()
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
        let query2 = PFQuery(className:"TapInfo")
        query2.whereKey("keycode", equalTo: m_txtKeyCode.text!)
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                object["redeemed"] = true
                var entries = object["entries"] as! Int
                entries = entries + 100
                object["entries"] = entries
                object.saveInBackground()
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
            
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "TAP.", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
