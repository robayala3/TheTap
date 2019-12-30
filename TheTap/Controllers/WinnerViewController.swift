//
//  WinnerViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/7/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse

class WinnerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var m_collectionView: UICollectionView!
    
    var m_imgArray = [String]()
    var m_amountArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        
        m_collectionView.dataSource = self
        m_collectionView.delegate = self
        
        // Resize size of collection view items in grid so that we achieve 3 boxes across
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 87 - 18 ) / 3
        let cellLayout = m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        loadCollectionViewData()
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
    
    func loadCollectionViewData() {
        
        m_imgArray.removeAll(keepCapacity: true)
        m_amountArray.removeAll(keepCapacity: true)
        m_collectionView.reloadData()
        
        // Build a parse query object
        let query = PFQuery(className:"TapInfo")
        query.whereKey("wins", greaterThanOrEqualTo: 1)
        query.orderByDescending("updatedAt")
        query.limit = 30
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Found \(objects?.count) Winners")
                for object in objects! {
                    self.m_imgArray.append(object["userEmail"] as! String)
                    self.m_amountArray.append(object["earnedMoney"] as! Int)
                }
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
            dispatch_async(dispatch_get_main_queue()){
                //reload the collection view
                self.m_collectionView.reloadData()
                query.cachePolicy = PFCachePolicy.NetworkElseCache
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_imgArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("winnercell", forIndexPath: indexPath) as! WinnerCLViewCell
        
        cell.layer.cornerRadius = 5
        
        let query = PFUser.query()!
        query.whereKey("email", equalTo: m_imgArray[indexPath.row])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Found \(objects?.count) Users")
                let object = objects![0] as! PFUser
                let avatar = object["avatar"] as! PFFile
                
                avatar.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.m_imgPhoto.image = UIImage(data:imageData)
                            cell.m_lblAmount.text = "$\(self.m_amountArray[indexPath.row])"
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
        return cell
    }
}
