//
//  AppDelegate.swift
//  TheTap
//
//  Created by Bluewide on 10/31/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse
import Contacts

import FBSDKCoreKit
import ParseFacebookUtilsV4


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KiipDelegate {

    var window: UIWindow?
    var store = CNContactStore()

    class func sharedDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("jEezDrMN5it39KDjyN0asme4taw9BzNR4Cr6au96", clientKey: "ZXIVUQVebd5x0jFOZ6BqbCbP9olYgB0sNbhypBmt")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        Chartboost.startWithAppId("564cda63f789824740027eb7", appSignature: "a7b0873f73173325ec56d065df1d894475bbd6cd", delegate: nil)        
        
        let kiip: Kiip = Kiip(appKey: "2792fb908f4c703e12b214927202e120", andSecret: "02594f1541fdc86087c9ae104fd53748")
        kiip.delegate = self
        Kiip.setSharedInstance(kiip)
        
        let appID = "564ce6abe13faa430100002f"
        let sdk = VungleSDK.sharedSDK()
        // start vungle publisher library
        sdk.startWithAppId(appID)
        
        NativeXSDK.initializeWithAppId("36534")
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkAccessStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            self.store.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    print("access denied")
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    func kiip(kiip:Kiip, contentId:NSString, quantity:Int, transactionId:NSString, signature:NSString) {
        // Add quantity amount of content to player's profile
        // e.g +20 coins to user's wallet
    }

}

