//
//  NTAParticipantsTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 11/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAParticipantsTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var tournament = PFObject(className: "Tournament")
    
    @IBAction func unwindToParticipants (segue : UIStoryboardSegue) {}
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let title = self.tournament["title"] as NSString
        self.navigationButton.setTitle(title, forState: .Normal)
        self.navigationButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.navigationButton.sizeToFit()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.becomeFirstResponder()
        self.nameTextField.attributedPlaceholder = NSAttributedString(string:"Enter participant name", attributes:[NSForegroundColorAttributeName: UIColor.appLightColor()])
        
        let barButtonItemFont = UIFont(name: "AvenirNext-DemiBold", size: 16)
        if let font = barButtonItemFont {
            self.startButton.setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
        }
        
        self.deleteButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.appRedColor()], forState: UIControlState.Normal)
    }
    
    @IBAction func startAction(sender: AnyObject) {
        if (self.tournament["participants"].count < 3) {
            let startAlertController = UIAlertController(title: nil, message: "You need at least 3 participants to start a tournament.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            startAlertController.addAction(OKAction)
            
            self.presentViewController(startAlertController, animated: true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier("startSegue", sender: self)
        }
    }
    
    func editAction(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("editSegue", sender: self)
    }
    
    @IBAction func toggleEdit(sender: AnyObject) {
        if (self.tableView.editing) {
            self.tableView.editing = false
            self.editButton.setTitle("Edit", forState: .Normal)
            self.nameTextField.enabled = true
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        else {
            self.tableView.editing = true
            self.editButton.setTitle("Done", forState: .Normal)
            self.nameTextField.enabled = false
            if self.tournament["participants"].count > 1 {
                self.navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }
    
    @IBAction func deleteParticipants(sender: AnyObject) {
        let deleteAlertController = UIAlertController(title: nil, message: "Are you sure you want to delete all participants?", preferredStyle: .Alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            self.tournament["participants"] = NSMutableArray()
            self.toggleEdit(self)
            self.tableView.reloadData()
            self.tournament.saveEventually()
        }
        deleteAlertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        deleteAlertController.addAction(cancelAction)
        
        self.presentViewController(deleteAlertController, animated: true, completion: nil)
    }
    
    @IBAction func shuffleParticipants(sender: AnyObject) {
        let shuffleAlertController = UIAlertController(title: nil, message: "Are you sure you want to shuffle participants?", preferredStyle: .Alert)
        
        let shuffleAction = UIAlertAction(title: "Shuffle", style: .Default) { (action) in
            let count = self.tournament["participants"].count
            for var index = count - 1; index > 0; index-- {
                // Random int from 0 to index-1
                var randomIndex = Int(arc4random_uniform(UInt32(index-1)))
                self.tournament["participants"].exchangeObjectAtIndex(index, withObjectAtIndex: randomIndex)
            }
            self.tableView.reloadData()
            self.tournament.saveEventually()
        }
        shuffleAlertController.addAction(shuffleAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        shuffleAlertController.addAction(cancelAction)
        
        self.presentViewController(shuffleAlertController, animated: true, completion: nil)
    }
    
    @IBAction func didTap(sender: AnyObject) {
        self.nameTextField.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.nameTextField.isFirstResponder()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as UITableViewCell
        
        let position = String(indexPath.row + 1)
        let positionLength = countElements(position) + 1
        let participant = self.tournament["participants"].objectAtIndex(indexPath.row) as NSDictionary
        let name = participant["name"] as NSString
        
        var attributedString = NSMutableAttributedString(string: position + ". " + name)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.appLightColor(), range: NSMakeRange(0, positionLength))
        
        cell.textLabel?.attributedText = attributedString
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let participantCount = self.tournament["participants"].count
        
        if participantCount < 1 {
            self.editButton.enabled = false
        }
        else {
            self.editButton.enabled = true
        }
        
        if self.tableView.editing && participantCount < 2 {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        return participantCount
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            self.tournament["participants"].removeObjectAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.reloadData()
            self.tournament.saveEventually()
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteRowAction = UITableViewRowAction(style: .Default, title: "Delete", handler:{action, index in
            self.tournament["participants"].removeObjectAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.reloadData()
            self.tournament.saveEventually()
        })
        
        deleteRowAction.backgroundColor = UIColor.appRedColor()
        
        return [deleteRowAction]
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let participant = self.tournament["participants"].objectAtIndex(sourceIndexPath.row) as [String:AnyObject]
        self.tournament["participants"].removeObjectAtIndex(sourceIndexPath.row)
        self.tournament["participants"].insertObject(participant, atIndex: destinationIndexPath.row)
        self.tableView.reloadData()
        self.tournament.saveEventually()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let text = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if self.tournament["participants"].count == 512 {
            let maxAlertController = UIAlertController(title: nil, message: "Maximum participants reached.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            maxAlertController.addAction(OKAction)
            
            self.presentViewController(maxAlertController, animated: true, completion: nil)
        }
        else if (text != "") {
            let participant = ["name": text]
            self.tournament["participants"].insertObject(participant, atIndex: 0)
            
            let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.reloadData()
            textField.text = ""
            
            // TODO: Contact Parse about lag caused by calling this many times. Because offline?
            self.tournament.saveEventually()
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editSegue") {
            let navigationController = segue.destinationViewController as UINavigationController
            var tableViewController = navigationController.topViewController as NTAEditTournamentTableViewController
            tableViewController.tournament = self.tournament
        }
        else if (segue.identifier == "startSegue") {
            let navigationController = segue.destinationViewController as UINavigationController
            var tableViewController = navigationController.topViewController as NTATypeTableViewController
            tableViewController.tournament = self.tournament
        }
    }

}
