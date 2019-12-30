//
//  TutorialViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/5/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse


class TutorialViewController: UIViewController {
    
    @IBOutlet weak var m_imgTut1: UIImageView!
    @IBOutlet weak var m_imgTut2: UIImageView!
    @IBOutlet weak var m_imgTut3: UIImageView!
    
    var m_nCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.  
        
        m_imgTut1.hidden = false
        m_imgTut2.hidden = true
        m_imgTut3.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    @IBAction func actionNext(sender: AnyObject) {
        m_nCount++
        
        if m_nCount == 1 {
            m_imgTut1.hidden = true
            m_imgTut2.hidden = false
            m_imgTut3.hidden = true
        } else if m_nCount == 2 {
            m_imgTut1.hidden = true
            m_imgTut2.hidden = true
            m_imgTut3.hidden = false
        } else {
            let currentUser = PFUser.currentUser()!
            currentUser["isNew"] = false
            currentUser.saveInBackgroundWithBlock(nil)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
