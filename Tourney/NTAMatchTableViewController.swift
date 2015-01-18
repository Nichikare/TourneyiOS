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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Match \(self.mid)"
        
        // This allows us to pass in altered match objects
        if match.isEmpty {
            self.match = self.appDelegate.getTournamentMatch(self.tournament, mid: self.mid)
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
    }

    @IBAction func saveAction(sender: AnyObject) {
        self.appDelegate.updateTournamentMatch(self.tournament, mid: self.mid, match: self.match)
        
        if winnerChanged == true {
            if self.tournament["type"] as NSString == "knockout" {
                // TODO move this code and improve, its ugly.
                // TODO add loser progression too.
                let filteredMatch = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["mid"] == self.mid})[0] as [String:Int]
                if let winnerMid = filteredMatch["winnerMid"] {
                    if let winnerWeight = filteredMatch["winnerWeight"] {
                        var winnerMatch = self.appDelegate.getTournamentMatch(self.tournament, mid: winnerMid)
                        if winnerMatch.isEmpty {
                            winnerMatch["participants"] = [0, 0]
                        }
                        var participants = winnerMatch["participants"] as [Int]
                        participants[winnerWeight] = self.match["winner"] as Int
                        winnerMatch["participants"] = participants
                        self.appDelegate.updateTournamentMatch(self.tournament, mid: winnerMid, match: winnerMatch)
                    }
                }
            }
        }
        
        self.tournament.saveEventually()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "winnerSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchWinnerTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.match = self.match
            tableViewController.delegate = self
        }
    }
    
    func updateValue(key: String, toValue:Int) {
        self.match[key] = toValue
        
        if (key == "winner") {
            self.winnerChanged = true
        }
        
        self.saveBarButton.enabled = true
    }
}
