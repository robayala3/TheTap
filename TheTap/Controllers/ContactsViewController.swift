//
//  ContactsViewController.swift
//  TheTap
//
//  Created by Bluewide on 11/19/15.
//  Copyright © 2015 Julia W. All rights reserved.
//

import UIKit
import Parse
import Contacts
import MessageUI

class ContactsViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var m_tableView: UITableView!
    @IBOutlet weak var m_searchText: UITextField!
    
    var m_fullName: String = "";
    var m_keyCode: String = "";
    
    var m_phonesToSend: [String] = []
    var textMessageRecipients: [String] = []
    
    var contacts: [CNContact] = []
    var contactStore = CNContactStore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        findAllContacts()
        
        m_searchText.delegate = self
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionTextChanged(sender: AnyObject) {
        let query = m_searchText.text!
        
        if query.isEmpty {
            findAllContacts()
        } else {
            findContactsWithName(query)
        }
    }
    
    @IBAction func actionBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func actionSendSMS(sender: AnyObject) {
        
        textMessageRecipients.removeAll()
        for recipient:String in m_phonesToSend {
            if recipient == "" {
                continue
            }
            textMessageRecipients.append(recipient)
        }        
        
        if (MFMessageComposeViewController.canSendText()) {
            let messageComposeVC = configuredMessageComposeViewController()
            self.presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {            
            showAlert("Your device is not able to send text messages.")
        }
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageBody = "\(m_fullName) invited you to TAP. You get 100 entries into this week's cash prize raffle, if you download the app and sign up. Make sure you enter the code \(m_keyCode)"
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = messageBody
        
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func findAllContacts() {
        AppDelegate.sharedDelegate().checkAccessStatus({ (accessGranted) -> Void in
            if accessGranted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    do {
                        self.contacts.removeAll()
                        try self.contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])) {
                            (contact, cursor) -> Void in
                            if (!contact.phoneNumbers.isEmpty){
                                //Add to your array
                                self.contacts.append(contact)
                            }
                        }
                        
                        self.m_phonesToSend.removeAll()
                        self.m_tableView.reloadData()
                    }
                    catch{
                        print("Handle the error please")
                    }
                })
            }
        })
    }
    
    func findContactsWithName(name: String) {
        AppDelegate.sharedDelegate().checkAccessStatus({ (accessGranted) -> Void in
            if accessGranted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    do {
                        let predicate: NSPredicate = CNContact.predicateForContactsMatchingName(name)
                        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                        self.contacts = try self.contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch:keysToFetch)
                        
                        self.m_phonesToSend.removeAll()
                        self.m_tableView.reloadData()
                    }
                    catch {
                        print("Unable to refetch the selected contact.")
                    }
                })
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "TAP.", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : ContactTableViewCell
        let cellId = "contactCell"
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ContactTableViewCell
        
        cell.m_lblFullName.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        cell.m_image.hidden = true
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
        currentCell.m_image.hidden = false
        view.endEditing(true)
        
        if contacts[indexPath.row].isKeyAvailable(CNContactPhoneNumbersKey) {
            for phoneNumber:CNLabeledValue in contacts[indexPath.row].phoneNumbers {
                let a = phoneNumber.value as! CNPhoneNumber
                m_phonesToSend.append(a.stringValue)
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
        currentCell.m_image.hidden = true
        
        if contacts[indexPath.row].isKeyAvailable(CNContactPhoneNumbersKey) {
            for phoneNumber:CNLabeledValue in contacts[indexPath.row].phoneNumbers {
                let a = phoneNumber.value as! CNPhoneNumber
                
                for var index = 0; index < m_phonesToSend.count; ++index {
                    if a.stringValue == m_phonesToSend[index] {
                        m_phonesToSend[index] = ""
                    }
                }
            }
        }
    }
    
}
