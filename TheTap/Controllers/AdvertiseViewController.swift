//
//  AdvertiseViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/11/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit

class AdvertiseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.  
    }
    
    override func viewWillAppear(animated: Bool) {
        Chartboost.showInterstitial(CBLocationGameScreen)
        
        Kiip.sharedInstance().saveMoment("tapped to get bonus", withCompletionHandler: {(poptart:KPPoptart!, error:NSError!) -> Void in
            if (error != nil) {
                /* handle error */
            }
            
            if (poptart == nil) {
                /* handle case with no reward to give*/
                print("Successful moment call but no reward to give.")
            }
            
            if (poptart != nil) {
                poptart.show()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
