//
//  NTAMatchTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

protocol NTAMatchTableViewControllerDelegate {
    func updateValue(key: String, toValue: AnyObject)
}

class NTAMatchTableViewController: UITableViewController, NTAMatchTableViewControllerDelegate, UITextViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var knockoutTableViewController: NTAKnockoutTableViewController?
    var tournament = PFObject(className: "Tournament")
    var mid = 0
    var match = [String:AnyObject]()
    
    // Set this to true to perform progression actions on save
    var winnerChanged: Bool = false
    
    // Determines if the date picker should be shown
    var editingDate: Bool = false
    
    @IBOutlet weak var winnerTableCell: UITableViewCell!
    @IBOutlet weak var scoresTableCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Match \(self.mid)"
        
        // This allows us to pass in altered match objects
        if self.match.isEmpty {
            self.match = self.appDelegate.getTournamentMatch(self.tournament, mid: self.mid)
        }
        
        // Remove notes text view padding.
        self.notesTextView.textContainer.lineFragmentPadding = 0
        self.notesTextView.textContainerInset = UIEdgeInsetsZero
        self.notesTextView.delegate = self
        
        if let notes = self.match["notes"] as? NSString {
            self.notesTextView.text = notes
            if (self.notesTextView.text == "") {
                self.notesTextView.text = "Notes"
                self.notesTextView.textColor = UIColor.lightGrayColor()
            }
            else {
                self.notesTextView.textColor = UIColor.blackColor()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let participants = self.match["participants"] as? NSArray {
            if let winnerIndex = self.match["winner"] as? Int {
                let winnerName = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: winnerIndex)
                self.winnerTableCell.detailTextLabel?.text = winnerName
            }
        }
        
        if let scores = self.match["scores"] as? [[Int]] {
            if scores.count > 0 {
                var scoreStrings: [String] = []
                for set in scores {
                    scoreStrings.append("\(String(set[0]))-\(String(set[1]))")
                }
                self.scoresTableCell.detailTextLabel?.text = ", ".join(scoreStrings)
            }
        }
    }

    @IBAction func saveAction(sender: AnyObject) {
        // Check for changes to the match notes.
        if let notes = self.match["notes"] as? NSString {
            if self.notesTextView.text != notes {
                if self.notesTextView.text == "Notes" {
                    self.match["notes"] = ""
                }
                else {
                    self.match["notes"] = self.notesTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                }
            }
        }
        else if self.notesTextView.text != "Notes" && self.notesTextView.text != "" {
            self.match["notes"] = self.notesTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
        self.appDelegate.updateTournamentMatch(self.tournament, mid: self.mid, match: self.match)
        
        // Advance participants if the winner has been changed.
        if winnerChanged == true {
            if self.tournament["type"] as NSString == "knockout" {
                let participants = self.match["participants"] as [Int]
                let winnerIndex = self.match["winner"] as Int
                let loserIndex = winnerIndex == participants[0] ? participants[1] : participants[0]
                
                let filteredMatch = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["mid"] == self.mid})[0] as [String:Int]
                
                // Advance winner.
                if let winnerMid = filteredMatch["winnerMid"] {
                    if let winnerWeight = filteredMatch["winnerWeight"] {
                        self.advanceParticipant(winnerIndex, nextMid: winnerMid, nextWeight: winnerWeight)
                    }
                }
                
                // Advance loser.
                if let loserMid = filteredMatch["loserMid"] {
                    if let loserWeight = filteredMatch["loserWeight"] {
                        self.advanceParticipant(loserIndex, nextMid: loserMid, nextWeight: loserWeight)
                    }
                }
            }
        }
        
        self.tournament.saveEventually()
        self.navigationController?.popViewControllerAnimated(true)        
        self.knockoutTableViewController?.refreshMatch(self.mid)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.textColor = UIColor.blackColor()
        if (textView.text == "Notes") {
            textView.text = ""
        }
        
        self.saveBarButton.enabled = true
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGrayColor()
        }
        
        if let notes = self.match["notes"] as? NSString {
            if self.notesTextView.text != notes {
                self.saveBarButton.enabled = true
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 1) { // Picker cell
            if self.editingDate {
                return 219
            }
            else {
                return 0
            }
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) { // Date cell
            self.editingDate = !self.editingDate
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Fade)
        }
    }
    
    // Helper function to advance a participant to a given match and weight.
    func advanceParticipant(participantIndex: Int, nextMid: Int, nextWeight: Int) {
        var nextMatch = self.appDelegate.getTournamentMatch(self.tournament, mid: nextMid)
        if nextMatch.isEmpty {
            nextMatch["participants"] = [0, 0]
        }
        var participants = nextMatch["participants"] as [Int]
        participants[nextWeight] = participantIndex
        nextMatch["participants"] = participants
        self.appDelegate.updateTournamentMatch(self.tournament, mid: nextMid, match: nextMatch)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "winnerSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchWinnerTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.match = self.match
            tableViewController.delegate = self
        }
        else if (segue.identifier == "scoresSegue") {
            let tableViewController = segue.destinationViewController as NTAScoresTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.match = self.match
            tableViewController.delegate = self
        }
    }
    
    // Delegate function to update local match data.
    func updateValue(key: String, toValue: AnyObject) {
        self.match[key] = toValue
        
        if (key == "winner") {
            self.winnerChanged = true
        }
        
        self.saveBarButton.enabled = true
    }
}
