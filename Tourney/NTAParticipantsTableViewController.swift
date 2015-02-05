//
//  NTAParticipantsTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 11/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAParticipantsTableViewController: UITableViewController {

    var tournament = PFObject(className: "Tournament")
    
    @IBAction func unwindToParticipants (segue : UIStoryboardSegue) {}
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.title! != self.tournament["title"] as NSString) {
            self.title = self.tournament["title"] as NSString
        }
        
        self.updateNameTextFieldEnabledState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.tournament["title"] as NSString
        self.nameTextField.becomeFirstResponder()
    }
    
    @IBAction func toggleEdit(sender: AnyObject) {
        if (self.tableView.editing) {
            self.tableView.editing = false
            self.editButton.setTitle("Edit List", forState: .Normal)
            self.editButton.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        }
        else {
            self.tableView.editing = true
            self.editButton.setTitle("Done", forState: .Normal)
            self.editButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        }
        
        self.updateNameTextFieldEnabledState()
    }
    
    func updateNameTextFieldEnabledState() {
        if (self.tableView.editing) {
            self.nameTextField.enabled = false
            self.nameTextField.text = ""
        }
        else {
            self.nameTextField.enabled = true
        }
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
    
    @IBAction func showActionSheet(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let startAction = UIAlertAction(title: "Start", style: .Default) { (action) in
            if (self.tournament["participants"].count < 2) {
                let startAlertController = UIAlertController(title: nil, message: "You need at least 2 participants to start a tournament.", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                startAlertController.addAction(OKAction)
                
                self.presentViewController(startAlertController, animated: true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("startSegue", sender: self)
            }
        }
        alertController.addAction(startAction)
        
        let editAction = UIAlertAction(title: "Edit", style: .Default) { (action) in
            self.performSegueWithIdentifier("editSegue", sender: self)
        }
        alertController.addAction(editAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as UITableViewCell
        
        let position = String(indexPath.row + 1)
        let positionLength = countElements(position) + 1
        let participant = self.tournament["participants"].objectAtIndex(indexPath.row) as NSDictionary
        let name = participant["name"] as NSString
        
        var attributedString = NSMutableAttributedString(string: position + ". " + name)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, positionLength))
        
        cell.textLabel?.attributedText = attributedString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tournament["participants"].count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            self.tournament["participants"].removeObjectAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.reloadData()
            self.tournament.saveEventually()
        }
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
        if (text != "") {
            let participant = ["name": text]
            self.tournament["participants"].insertObject(participant, atIndex: 0)
            
            let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.reloadData()
            
            textField.text = ""
            
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
