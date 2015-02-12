//
//  NTAMatchWinnerTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAMatchWinnerTableViewController: UITableViewController {

    @IBOutlet weak var cellA: UITableViewCell!
    @IBOutlet weak var cellB: UITableViewCell!
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var tournament = PFObject(className: "Tournament")
    var match = [String:AnyObject]()
    var mid: Int = 0
    var delegate: NTAMatchTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let participants = self.match["participants"] as? NSArray {
            let indexA = participants[0] as NSInteger
            let indexB = participants[1] as NSInteger
            self.cellA.textLabel?.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexA)
            self.cellB.textLabel?.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexB)

            if let winner = self.match["winner"] as? Int {
                if winner == indexA {
                    self.cellA.accessoryType = .Checkmark
                }
                else if winner == indexB {
                    self.cellB.accessoryType = .Checkmark
                }
            }
            
            if self.delegate?.getValue("winner") as NSObject != NSNull() {
                self.cellA.textLabel?.enabled = false
                self.cellB.textLabel?.enabled = false
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && self.delegate?.getValue("winner") as NSObject == NSNull() {
            // Only show the Reset button when a winner is saved.
            return 0
        }
        else {
            return super.tableView(self.tableView, numberOfRowsInSection:section)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if self.delegate?.getValue("winner") as NSObject == NSNull() {
                if let participants = self.match["participants"] as? NSArray {
                    if indexPath.row == 0 {
                        self.delegate?.updateValue("winner", toValue: participants[0] as Int)
                        self.cellA.accessoryType = .Checkmark
                        self.cellB.accessoryType = .None
                    }
                    else {
                        self.delegate?.updateValue("winner", toValue: participants[1] as Int)
                        self.cellA.accessoryType = .None
                        self.cellB.accessoryType = .Checkmark
                    }
                }
            }
        }
        else if indexPath.section == 1 && indexPath.row == 0 {  
            var showAlert = false
            
            // Check that both the winnerMid and loserMid have no winner set
            let matchInfo = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["mid"] == self.mid})[0] as [String:Int]
            if let winnerMid = matchInfo["winnerMid"] {
                let nextMatch = self.appDelegate.getTournamentMatch(self.tournament, mid: winnerMid)
                if nextMatch.indexForKey("winner") != nil {
                    showAlert = true
                }
            }
            if let loserMid = matchInfo["loserMid"] {
                let nextMatch = self.appDelegate.getTournamentMatch(self.tournament, mid: loserMid)
                if nextMatch.indexForKey("winner") != nil {
                    showAlert = true
                }
            }
            
            if showAlert {
                let resetAlertController = UIAlertController(title: nil, message: "This match cannot be reset because its next match has a winner.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                resetAlertController.addAction(OKAction)
                self.presentViewController(resetAlertController, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: true)
            }
            else {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

                alertController.message = "Are you sure? The match winner and score will be reset."
                
                let destroyAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
                    // Reset match winners.
                    self.delegate?.resetWinner()
                    self.navigationController?.popViewControllerAnimated(true)
                }
                alertController.addAction(destroyAction)

                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}
