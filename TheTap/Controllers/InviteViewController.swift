//
//  InviteViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/7/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Parse
import FBSDKShareKit

class InviteViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var m_lblKeyCode: UILabel!
    
    var m_fullName: String = "";
    var m_keyCode: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let curUser = PFUser.currentUser()!
        let query = PFQuery(className:"TapInfo")
        query.whereKey("userEmail", equalTo: curUser.email!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                self.m_lblKeyCode.text = object["keycode"] as? String
                
                self.m_fullName = object["fullname"] as! String
                self.m_keyCode = object["keycode"] as! String
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
        }        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func actionSendEmail(sender: AnyObject) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            showAlert("Could Not Send Email")
        }
    }
    
    @IBAction func actionFBInvite(sender: AnyObject) {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: "https://test/myapplink")
        content.appInvitePreviewImageURL = NSURL(string: "https://test/myapplink")
        //FBSDKAppInviteDialog.showWithContent(content, delegate: self)
        
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailBody = "<p>\(m_fullName) invited you to TAP. You get 100 entries into this week's cash prize raffle, if you download the app and sign up. Make sure you enter the code \(m_keyCode)</p>"
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("TAP.")
        mailComposerVC.setMessageBody(mailBody, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "TAP.", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

extension InviteViewController: FBSDKAppInviteDialogDelegate {
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //TODO
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        //TODO
    }
}

