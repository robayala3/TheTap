//
//  HomeViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/2/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import Parse

class HomeViewController: UIViewController {
    
    @IBOutlet weak var m_lblTaps: UILabel!
    @IBOutlet weak var m_lblEntries: UILabel!
    @IBOutlet weak var m_lblMoney: UILabel!
    @IBOutlet weak var m_btnTap0: UIButton!
    @IBOutlet weak var m_btnTap1: UIButton!
    @IBOutlet weak var m_btnTap2: UIButton!
    @IBOutlet weak var m_btnTap3: UIButton!
    @IBOutlet weak var m_imgCircle: UIImageView!
    
    @IBOutlet weak var m_lblTimeCount: UILabel!
    
    @IBOutlet weak var m_raffleView: UIView!
    @IBOutlet weak var m_animate: UIImageView!
    @IBOutlet weak var m_lblCountDown: UILabel!
    
    @IBOutlet weak var m_winnerView: UIView!
    @IBOutlet weak var m_imgWinner: UIImageView!
    @IBOutlet weak var m_lblWinnerName: UILabel!
    
    
    var m_tapInfo: PFObject! = nil
    var m_nTaps: Int = 0

    var m_nEntries: Int = 0
    var m_bRaffling: Bool = false
    var m_nRemainSecs: Int = 0
    var m_timer: NSTimer = NSTimer()
    
    var m_bRaffleViewShown: Bool = false
    var m_bWinnerViewShown: Bool = false    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        m_raffleView.hidden = true
        m_winnerView.hidden = true
        
        m_tapInfo = nil
        m_nTaps = 0
        m_nEntries = 0
        
        m_btnTap0.hidden = true
        m_btnTap1.hidden = true
        m_btnTap2.hidden = true
        m_btnTap3.hidden = true
        
        m_lblMoney.hidden = true
        m_imgCircle.hidden = true
        
        m_bRaffleViewShown = false
        m_bWinnerViewShown = false
        
        m_animate.image = UIImage.gifWithName("raffle")
        
        initTime()
        
        m_timer.invalidate()
        m_timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("calculateTime:"), name:UIApplicationDidBecomeActiveNotification, object: nil);
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func calculateTime(sender: NSNotification) {
        initTime()
    }
    
    func initTime() {
        let curTime = getServerTime()
        
        let formatter = NSDateFormatter();
        formatter.timeZone = NSTimeZone(abbreviation: "UTC");
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let currentDateTime = formatter.dateFromString(curTime)
        
        //get EST time
        formatter.timeZone = NSTimeZone(abbreviation: "EST");
        let estTimeZoneStr = formatter.stringFromDate(currentDateTime!);
        
        formatter.timeZone = NSTimeZone(abbreviation: "UTC");
        let estDate = formatter.dateFromString(estTimeZoneStr)! as NSDate
        
        //let curDayOfWeek = getDayOfWeek(estTimeWeekDay)
        //let curSecs = currentDateTime.timeIntervalSince1970
        
        
        // get the user's calendar
        let userCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        userCalendar.timeZone = NSTimeZone(abbreviation: "UTC")!;
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Weekday,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: estDate)
        
        let diffSecs = (dateTimeComponents.weekday-1)*24*60*60 + (dateTimeComponents.hour*60*60 + dateTimeComponents.minute*60) - (20*60*60)
        m_nRemainSecs = (diffSecs > 0) ? (7*24*60*60 - diffSecs) : -diffSecs
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            if currentUser?.objectForKey("isNew")?.boolValue == true {
                self.performSegueWithIdentifier("tutorial", sender: self)
                return
            }
            
            if m_tapInfo == nil {
                let query = PFQuery(className:"TapInfo")
                query.whereKey("userEmail", equalTo: currentUser!["email"])
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        print("Successfully retrieved \(objects!.count) objects.")
                        self.m_tapInfo = objects![0]
                        
                        self.m_nTaps = self.m_tapInfo["taps"] as! Int
                        self.m_nEntries = self.m_tapInfo["entries"] as! Int
                        
                        let nIndex = (self.m_nTaps / 400) % 4
                        let nArrayIdx = (self.m_nTaps % 400) / 20 + 1
                        
                        switch nIndex {
                        case 0:
                            self.m_lblMoney.hidden = false
                            self.m_imgCircle.hidden = true
                            
                            self.m_btnTap3.hidden = true
                            self.m_btnTap0.hidden = false
                            break
                        case 1:
                            self.m_lblMoney.hidden = false
                            self.m_imgCircle.hidden = false
                            
                            self.m_btnTap1.hidden = false
                            self.m_btnTap0.hidden = true
                            break
                        case 2:
                            self.m_lblMoney.hidden = false
                            self.m_imgCircle.hidden = true
                            
                            self.m_btnTap2.hidden = false
                            self.m_btnTap1.hidden = true
                            break
                        case 3:
                            self.m_lblMoney.hidden = true
                            self.m_imgCircle.hidden = false
                            
                            self.m_btnTap3.hidden = false
                            self.m_btnTap2.hidden = true
                            break
                        default:
                            break
                        }
                        
                        if nIndex == 0 {
                            self.m_btnTap0.setBackgroundImage(UIImage(named: "gatorade/gatorade\(nArrayIdx).png"), forState: UIControlState.Normal)
                        } else if nIndex == 2 {
                            self.m_btnTap2.setBackgroundImage(UIImage(named: "beer/beer\(nArrayIdx).png"), forState: UIControlState.Normal)
                        } else {
                            if nArrayIdx == 1 {
                                self.m_imgCircle.image = UIImage(named: "circle.png")
                            } else {
                                self.m_imgCircle.image = UIImage(named: "circle/circle\(nArrayIdx-1).png")
                            }
                        }
                        
                        let formatter = NSNumberFormatter()
                        formatter.numberStyle = .DecimalStyle
                        formatter.maximumFractionDigits = 0
                        self.m_lblTaps.text = formatter.stringFromNumber(self.m_nTaps)
                        self.m_lblEntries.text = "Entries: " + formatter.stringFromNumber(self.m_nEntries)!
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            }
        } else {
            // Show the signup or login screen
            //let startVC = self.storyboard?.instantiateViewControllerWithIdentifier("StartVC")
            //self.presentViewController(startVC!, animated: false, completion: nil)
            self.performSegueWithIdentifier("start", sender: self)
        }
        
    }
    
    func update() {
        var nCountToDraw = m_nRemainSecs - 3600
        if nCountToDraw <= 0 {
            nCountToDraw = 0
        }
        let nDay = nCountToDraw / (24 * 60 * 60)
        let nHour = (nCountToDraw - nDay * 24 * 60 * 60) / (60 * 60)
        var nMinute = (nCountToDraw - nDay * 24 * 60 * 60 - nHour * 60 * 60) / 60
        var nSecs = nCountToDraw - nDay * 24 * 60 * 60 - nHour * 60 * 60 - nMinute * 60
        
        if nCountToDraw > 0 {
            //m_lblTimeCount.text = "Countdown to Draw: \(nDay)d \(nHour)h \(nMinute)m \(nSecs)s"
            m_lblTimeCount.text = String(format: "Countdown to Draw: %dd %02dh %02dm %02ds", arguments: [nDay, nHour, nMinute, nSecs])
        } else {
            m_lblTimeCount.text = "Countdown to Draw: 0d 0h 0m 0s"
        }
        
        if m_nRemainSecs <= 3600 && m_bRaffleViewShown == false {
            m_raffleView.hidden = false
            m_winnerView.hidden = true
            m_bRaffleViewShown = true
        } else if m_nRemainSecs <= 1800 && m_bWinnerViewShown == false {
            // Build a parse query object
            let query = PFQuery(className:"TapInfo")
            query.whereKey("isWinner", equalTo: true)
            query.orderByDescending("entries")
            query.limit = 1
            // Fetch data from the parse platform
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    print("Found \(objects?.count) Winners")
                    if objects?.count == 1 {
                        let object = objects![0]
                        let winnerEmail = object["userEmail"]
                        self.m_lblWinnerName.text = object["fullname"] as? String
                        
                        let subquery = PFUser.query()!
                        subquery.whereKey("email", equalTo: winnerEmail)
                        subquery.findObjectsInBackgroundWithBlock {
                            (userobjects: [PFObject]?, usererror: NSError?) -> Void in
                            if error == nil {
                                print("Found \(userobjects?.count) Users")
                                
                                let userobject = userobjects![0] as! PFUser
                                let avatar = userobject["avatar"] as! PFFile
                                
                                avatar.getDataInBackgroundWithBlock {
                                    (imageData: NSData?, imgerror: NSError?) -> Void in
                                    if imgerror == nil {
                                        if let imageData = imageData {
                                            self.m_imgWinner.image = UIImage(data:imageData)
                                        }
                                    }
                                }
                                
                                self.m_raffleView.hidden = true
                                self.m_winnerView.hidden = false
                                self.m_bWinnerViewShown = true
                            } else {
                                // Log details of the failure
                                print("Error: \(usererror) \(usererror!.userInfo)")
                            }
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error) \(error!.userInfo)")
                }
            }
        }
        
        if m_bRaffleViewShown == true {
            var nCountDown = m_nRemainSecs - 1800
            if nCountDown <= 0 {
                nCountDown = 0;
            }
            
            nMinute = nCountDown / 60
            nSecs = nCountDown % 60
            
            if nCountDown > 0 {
                m_lblCountDown.text = String(format: "%02d:%02d", arguments: [nMinute, nSecs])
            } else {
                m_lblCountDown.text = "00:00"
            }
        }
        
        m_nRemainSecs--
        
        if (m_nRemainSecs == 0) {
            m_raffleView.hidden = true
            m_raffleView.hidden = true
            
            m_bRaffleViewShown = false
            m_bWinnerViewShown = false
            
            initTime()
            //m_nRemainSecs = getRemainTime()
            m_nTaps = 0
            m_nEntries = 0
            
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            formatter.maximumFractionDigits = 0
            m_lblTaps.text = formatter.stringFromNumber(m_nTaps)
            m_lblEntries.text = "Entries: " + formatter.stringFromNumber(m_nEntries)!
            
            self.m_lblMoney.hidden = true
            
            m_btnTap0.hidden = false
            m_btnTap1.hidden = true
            m_btnTap2.hidden = true
            m_btnTap3.hidden = true
        }
    }
    
    @IBAction func actionMenu(sender: AnyObject) {
        if revealViewController() != nil {
            revealViewController().revealToggle(sender)
        }
    }
    
    @IBAction func actionRaffleTap(sender: AnyObject) {
        updateTapEntries(-1)
    }
    
    @IBAction func actionTap0(sender: AnyObject) {
        updateTapEntries(0)
    }
    
    @IBAction func actionTap1(sender: AnyObject) {
        updateTapEntries(1)
    }
    
    @IBAction func actionTap2(sender: AnyObject) {
        updateTapEntries(2)
    }
    
    @IBAction func actionTap3(sender: AnyObject) {
        updateTapEntries(3)
    }
    
    func updateTapEntries(buttonIndex: Int) {
        if m_tapInfo == nil {
            print("Error: There is no object")
            return
        }        
        
        m_nTaps++
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        m_lblTaps.text = formatter.stringFromNumber(m_nTaps)
        
        if m_nTaps % 20 == 0 {
            m_nEntries++
            m_lblEntries.text = "Entries: " + formatter.stringFromNumber(m_nEntries)!
        }
        
        m_tapInfo["taps"] = m_nTaps
        m_tapInfo["entries"] = m_nEntries
        
        m_tapInfo.saveInBackground()
        let nIndex = (m_nTaps / 400) % 4
        
        if m_nTaps % 400 == 0 {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
            
            switch nIndex {
            case 0:
                self.m_lblMoney.hidden = false
                self.m_imgCircle.hidden = true
                
                self.m_btnTap3.hidden = true
                self.m_btnTap0.hidden = false
                m_btnTap0.setBackgroundImage(UIImage(named: "gatorade/gatorade1.png"), forState: UIControlState.Normal)
                
                break
            case 1:
                self.m_lblMoney.hidden = false
                self.m_imgCircle.hidden = false
                
                self.m_btnTap1.hidden = false
                self.m_btnTap0.hidden = true
                self.m_imgCircle.image = UIImage(named: "circle.png")
                
                break
            case 2:
                self.m_lblMoney.hidden = false
                self.m_imgCircle.hidden = true
                
                self.m_btnTap2.hidden = false
                self.m_btnTap1.hidden = true
                m_btnTap2.setBackgroundImage(UIImage(named: "beer/beer1.png"), forState: UIControlState.Normal)
                
                break
            case 3:
                self.m_lblMoney.hidden = true
                self.m_imgCircle.hidden = false
                
                self.m_btnTap3.hidden = false
                self.m_btnTap2.hidden = true
                self.m_imgCircle.image = UIImage(named: "circle.png")
                
                break
            default:
                break
            }
            
            if m_bRaffling == false {
                m_nEntries += 100
                m_lblEntries.text = "Entries: " + formatter.stringFromNumber(m_nEntries)!
                
                m_tapInfo["entries"] = m_nEntries
                m_tapInfo.saveInBackground()
                
                self.performSegueWithIdentifier("advertise", sender: self)
            }
        }
        
        let nArrayIdx = (m_nTaps % 400) / 20 + 1
        
        if m_nTaps % 20 == 0 {
            if buttonIndex == 0 || nIndex == 0 {
                m_btnTap0.setBackgroundImage(UIImage(named: "gatorade/gatorade\(nArrayIdx).png"), forState: UIControlState.Normal)
            } else if buttonIndex == 2 || nIndex == 2 {
                m_btnTap2.setBackgroundImage(UIImage(named: "beer/beer\(nArrayIdx).png"), forState: UIControlState.Normal)
            } else if (buttonIndex == 1 || nIndex == 1) || (buttonIndex == 3 || nIndex == 3) {
                if nArrayIdx == 1 {
                    self.m_imgCircle.image = UIImage(named: "circle.png")
                } else {
                    self.m_imgCircle.image = UIImage(named: "circle/circle\(nArrayIdx-1).png")
                }
            }
        }
    }
    
    func getDayOfWeek(today:String)->Int {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(NSCalendarUnit.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        
        return weekDay
    }
    
    func getServerTime()->String {
        let parameters = ["": ""]
        
        do {
           let result = try PFCloud.callFunction("getCurrentDate", withParameters: parameters)
            print(result)
            return result as! String
        }
        catch {
            print("Unable to call cloud function.")
            return ""
        }
    }
    
}

