//
//  NTAMatchTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

protocol NTAMatchTableViewControllerDelegate {
    func updateValue(key: String, toValue:Int)
}

class NTAMatchTableViewController: UITableViewController, NTAMatchTableViewControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var tournament = PFObject(className: "Tournament")
    var mid = 0
    var match = [String:AnyObject]()
    
    // Set this to true to perform progression actions on save
    var winnerChanged: Bool = false
    
    @IBOutlet weak var winnerTableCell: UITableViewCell!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Match \(self.mid)"
        
        // This allows us to pass in altered match objects
        if match.isEmpty {
            self.match = self.appDelegate.getTournamentMatch(self.tournament, mid: self.mid)
        }
        
        // Remove notes text view padding.
        self.notesTextView.textContainer.lineFragmentPadding = 0
        self.notesTextView.textContainerInset = UIEdgeInsetsZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let participants = self.match["participants"] as? NSArray {
            if let winnerIndex = self.match["winner"] as? Int {
                let winnerName = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: winnerIndex)
                self.winnerTableCell.detailTextLabel?.text = winnerName
            }
        }
    }

    @IBAction func saveAction(sender: AnyObject) {
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
    }
    
    // Delegate function to update local match data.
    func updateValue(key: String, toValue:Int) {
        self.match[key] = toValue
        
        if (key == "winner") {
            self.winnerChanged = true
        }
        
        self.saveBarButton.enabled = true
    }
}
