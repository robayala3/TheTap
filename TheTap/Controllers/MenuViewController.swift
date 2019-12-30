//
//  MenuViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/4/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
        }
    }
    
}