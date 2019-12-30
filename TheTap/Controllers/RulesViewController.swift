//
//  RulesViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/17/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {
    
    @IBOutlet weak var m_webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        m_webView.opaque = false
        let localfilePath = NSBundle.mainBundle().URLForResource("rules", withExtension: "html");
        let _request = NSURLRequest(URL: localfilePath!);
        m_webView.loadRequest(_request);
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
}
