//
//  ViewController.swift
//  TheTap
//
//  Created by Bluewide on 10/31/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

import FBSDKCoreKit
import ParseFacebookUtilsV4

class ViewController: UIViewController {   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            // Show the signup or login screen
        }

    }    
    
    @IBAction func actionFBLogin(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile","email"], block: { (user:PFUser?, error:NSError?) -> Void in
            
            if error != nil {
                self.showAlert(error!.localizedDescription)
                return
            }
            
            print(user)
            print("Current user token=\(FBSDKAccessToken.currentAccessToken().tokenString)")
            
            print("Current user id \(FBSDKAccessToken.currentAccessToken().userID)")
            
            if FBSDKAccessToken.currentAccessToken() != nil {
                self.updateUserDetail()
            }
            
        })
    }
    
    func updateUserDetail() {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if error != nil {
                print("\(error.localizedDescription)")
                return
            }
            
            if result != nil {
                
                let userId:String = result["id"] as! String
                let userFirstName:String? = result["first_name"] as? String
                let userLastName:String? = result["last_name"] as? String
                let userEmail:String? = result["email"] as? String
                
                let currentUser : PFUser = PFUser.currentUser()!
                
                let firstName:String? = currentUser.objectForKey("firstname") as? String
                if firstName != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                }
                
                // Save first name
                if userFirstName != nil {
                    currentUser.setObject(userFirstName!, forKey: "firstname")
                    
                }
                
                //Save last name
                if userLastName != nil {
                    currentUser.setObject(userLastName!, forKey: "lastname")
                }
                
                // Save email address
                if userEmail != nil {
                    currentUser.setObject(userEmail!, forKey: "email")
                    currentUser.setObject(userEmail!, forKey: "username")
                }
                
                currentUser["isNew"] = true
                currentUser["loggedInFB"] = true
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    let profilePictureUrl = NSURL(string: userProfile)
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    
                    if profilePictureData != nil {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        currentUser.setObject(profileFileObject!, forKey: "avatar")
                    }                    
                    
                    currentUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if success {
                            print("User details are now updated")
                            let tapInfo = PFObject(className:"TapInfo")
                            tapInfo["userEmail"] = userEmail
                            tapInfo["fullname"] = userFirstName! + " " + userLastName!
                            tapInfo["byFacebook"] = true
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
                                    print("User updated successfully")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    // There was a problem, check error.description
                                }
                            }
                        }
                    })
                }
            }
        }
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

