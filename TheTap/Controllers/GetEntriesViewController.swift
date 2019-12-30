//
//  GetEntriesViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/6/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse
import Social
import FBSDKShareKit

class GetEntriesViewController: UIViewController, VungleSDKDelegate, NativeXRewardDelegate, FBSDKSharingDelegate {
    
    var m_fullName: String = "";
    var m_keyCode: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*if revealViewController() != nil {
            //revealViewController().rearViewRevealWidth = 62
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }*/
        
        let curUser = PFUser.currentUser()!
        let query = PFQuery(className:"TapInfo")
        query.whereKey("userEmail", equalTo: curUser.email!)
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                self.m_fullName = object["fullname"] as! String
                self.m_keyCode = object["keycode"] as! String
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
        NativeXSDK.fetchAdsAutomaticallyWithPlacement(kAdPlacementPlayerGeneratedEvent)
        NativeXSDK.fetchAdsAutomaticallyWithName("player-generated-event")
        NativeXSDK.setRewardDelegate(self)
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
    
    @IBAction func actionShareFB(sender: AnyObject) {
        /*if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookSheet.completionHandler = {
                result in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    break
                case SLComposeViewControllerResult.Done:
                    self.addEntries(50)
                    break
                }
            }
            
            let initText = "\(m_fullName) invited you to TAP. You get 50 entries into this week cash prize raffle, if you sign up through this link and enter code \(m_keyCode)"
            facebookSheet.setInitialText(initText)
            self.presentViewController(facebookSheet, animated: true, completion: {})
            facebookSheet.setInitialText(initText)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }*/
        let initText = "\(m_fullName) invited you to TAP. You get 50 entries into this week's cash prize raffle, if you download the app and sign up. Make sure you enter the code \(m_keyCode)"
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent.init()
        content.contentDescription = initText        
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)        
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        if results["postId"] != nil {
            print("Success to share via Facebook")
            self.addEntries(50)
        } else {
            print("Cancelled to share via Facebook")
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("Failed to share via Facebook")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("Cancelled to share via Facebook")
    }
    
    @IBAction func actionTweet(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            twitterSheet.completionHandler = {
                result in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    break
                case SLComposeViewControllerResult.Done:
                    self.addEntries(50)
                    break
                }
            }
            
            let initText = "\(m_fullName) invited you to TAP. You get 50 entries into this week's cash prize raffle, if you download the app and sign up. Make sure you enter the code \(m_keyCode)"
            twitterSheet.setInitialText(initText)
            self.presentViewController(twitterSheet, animated: true, completion: {})
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionWatchVideo(sender: AnyObject) {
        let sdk = VungleSDK.sharedSDK()
        sdk.delegate = self
        
        if sdk.isAdPlayable() {
            do {
                try sdk.playAd(self, error: {}())
            } catch {}
        } else {
            showAlert("Video is not available at this moment")
        }
    }
    
    @IBAction func actionOfferReward(sender: AnyObject) {
        
        if NativeXSDK.isAdFetchedWithPlacement(kAdPlacementPlayerGeneratedEvent) {
            NativeXSDK.showAdWithPlacement(kAdPlacementPlayerGeneratedEvent)
        }
        
        if NativeXSDK.isAdFetchedWithName("player-generated-event") {
            NativeXSDK.showAdWithName("player-generated-event")
        }
    }
    
    // Vungle delegate
    func vungleSDKwillCloseAdWithViewInfo(viewInfo: [NSObject : AnyObject]!, willPresentProductSheet: Bool) {
        print(viewInfo)
        addEntries(50)
    }
    
    func addEntries(nValue: Int) {
        let curUser = PFUser.currentUser()!
        let query = PFQuery(className:"TapInfo")
        query.whereKey("userEmail", equalTo: curUser.email!)
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let object = objects![0] as PFObject
                var entries = object["entries"] as! Int
                entries = entries + nValue
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
    
    func rewardAvailable(rewardInfo: NativeXRewardInfo!) {
        //let rm = NXRewardsManager.sharedInstance
        
        for reward in rewardInfo.rewards {
            let amount = reward.amount as Int
            
            let curUser = PFUser.currentUser()!
            let query = PFQuery(className:"TapInfo")
            query.whereKey("userEmail", equalTo: curUser.email!)
            // Fetch data from the parse platform
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    let object = objects![0] as PFObject
                    var entries = object["entries"] as! Int
                    entries = entries + amount
                    object["entries"] = entries
                    object.saveInBackground()
                } else {
                    // Log details of the failure
                    print("Error: \(error) \(error!.userInfo)")
                }
            }
        }
    }
    
}