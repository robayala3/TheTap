//
//  LeaderboardViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/5/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var m_tableView: UITableView!
    @IBOutlet weak var m_lblReport: UILabel!
    
    var m_nameArray = [String]()
    var m_tapsArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        m_tableView.delegate = self
        m_tableView.dataSource = self
        
        m_nameArray.removeAll(keepCapacity: true)
        m_tapsArray.removeAll(keepCapacity: true)
        m_tableView.reloadData()
        
        m_lblReport.hidden = true
        
        let curUser = PFUser.currentUser()!        
        
        if curUser.objectForKey("loggedInFB")?.boolValue == false {
            m_lblReport.hidden = false
            m_tableView.hidden = true
            return
        }
        
        let query = PFQuery(className: "TapInfo")
        query.whereKey("byFacebook", equalTo: true)
        query.orderByDescending("taps")
        query.limit = 50
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                for object in objects! {
                    self.m_nameArray.append(object["fullname"] as! String)
                    self.m_tapsArray.append(object["taps"] as! Int)
                }
                
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
            dispatch_async(dispatch_get_main_queue()) {
                //reload the table view
                self.m_tableView.reloadData()
                query.cachePolicy = PFCachePolicy.NetworkElseCache
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
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 33
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return m_nameArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : LBTableViewCell
        let cellId = "leaderboardCell"
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! LBTableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.nameLabel!.text = m_nameArray[indexPath.row]
        cell.orderLabel!.text = String(indexPath.row + 1)
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        cell.scoreLabel!.text = formatter.stringFromNumber(m_tapsArray[indexPath.row])
        
        return cell
    }
    
}
