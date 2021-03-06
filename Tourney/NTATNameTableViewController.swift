//
//  NTATNameTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 09/11/2014.
//  Copyright (c) 2014 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTATNameTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func nameTextFieldChanged(sender: AnyObject) {
        let text = self.nameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (text == "") {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.nameTextField.textColor = UIColor.whiteColor()
        }
    }
    
    // Set this to true in a prepareForSegue to create a new tournament when Done is pressed.
    var createNewTournament = false;
    
    // Passed in when editing a tournament.
    var tournament = PFObject(className: "Tournament")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (createNewTournament) {
            self.title = "New"
            var rightButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneButtonAction")
            self.navigationItem.rightBarButtonItem = rightButton
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            self.title = "Name"
            var rightButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "saveButtonAction")
            self.navigationItem.rightBarButtonItem = rightButton
            self.nameTextField.text = self.tournament["title"] as! NSString as String
        }
        
        let barButtonItemFont = UIFont(name: "AvenirNext-DemiBold", size: 16)
        if let font = barButtonItemFont {
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
        }
        
        var cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelButtonAction")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }

    func doneButtonAction() {
        var tournament = PFObject(className:"Tournament")
        var acl = PFACL(user: PFUser.currentUser()!)
        acl.setPublicReadAccess(true)
        tournament.ACL = acl
        tournament["createdBy"] = PFUser.currentUser()
        tournament["title"] = self.nameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        tournament["participants"] = NSMutableArray()
        tournament.saveEventually()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let navigationController = self.appDelegate.initialViewController as! UINavigationController
        let viewController = navigationController.topViewController as! NTATournamentListTableViewController
        viewController.tournaments.insert(tournament, atIndex: 0)
        viewController.performSegueWithIdentifier("participantSegue", sender: tournament)
    }
    
    func cancelButtonAction() {
        if (createNewTournament) {
            performSegueWithIdentifier("unwindToList", sender: self)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func saveButtonAction() {
        tournament["title"] = self.nameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        tournament.saveEventually()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.appLightColor()
        header.textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
}