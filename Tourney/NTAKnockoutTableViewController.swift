//
//  NTAKnockoutTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 11/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

protocol NTAKnockoutTableViewControllerDelegate {
    func setWinner(mid: Int, index: Int)
}

class NTAKnockoutTableViewController: UITableViewController, NTAKnockoutTableViewControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var pageViewController: NTAKnockoutPageViewController?
    var tournament = PFObject(className: "Tournament")
    var pageIndex = 0    
    var matches = [[String:Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Number of matches in this round.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.matches.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let mid = self.matches[section]["mid"] {
            return "Match " + String(mid)
        }
        
        return "Match"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as NTAKnockoutMatchTableViewCell
        cell.delegate = self

        if let mid = self.matches[indexPath.section]["mid"] {
            // Save data to the cell.
            cell.mid = mid
            
            let match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
            
            if let participants = match["participants"] as? NSArray {
                let indexA = participants[0] as Int
                let indexB = participants[1] as Int
                
                // TODO What if both -1? Can this happen?
                if indexA == -1 {
                    cell.nameALabel.text = "BYE"
                }
                else {
                    cell.nameALabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexA)
                    cell.nameALabel.font = UIFont.systemFontOfSize(16.0)
                    cell.nameALabel.textColor = UIColor.blackColor()
                }
                
                if indexB == -1 {
                    cell.nameBLabel.text = "BYE"
                }
                else {
                    cell.nameBLabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexB)
                    cell.nameBLabel.font = UIFont.systemFontOfSize(16.0)
                    cell.nameBLabel.textColor = UIColor.blackColor()
                }
                
                if let winner = match["winner"] as? Int {
                    if winner == indexA {
                        cell.nameALabel.font = UIFont.boldSystemFontOfSize(16.0)
                        cell.nameALabel.textColor = UIColor.greenColor()
                    }
                    else if winner == indexB {
                        cell.nameBLabel.font = UIFont.boldSystemFontOfSize(16.0)
                        cell.nameBLabel.textColor = UIColor.greenColor()
                    }
                    
                    cell.winnerAButton.hidden = true
                    cell.winnerBButton.hidden = true

                    if let scores = match["scores"] as? [[Int]] {
                        if scores.count > 0 {
                            var scoreA = 0;
                            var scoreB = 0;
                            for set in scores {
                                if set[0] > set[1] {
                                    // A wins
                                    scoreA = scoreA + 1
                                }
                                else if set[1] > set[0] {
                                    // B wins
                                    scoreB = scoreB + 1
                                }
                            }
                            cell.scoreALabel.text = String(scoreA)
                            cell.scoreBLabel.text = String(scoreB)
                            cell.scoreALabel.hidden = false
                            cell.scoreBLabel.hidden = false
                        }
                    }
                    // TODO show check icon
                }
            }
        }

        return cell
    }
    
    func refreshMatch(mid: Int) {
        for (index, match) in enumerate(matches) {
            if match["mid"] == mid {
                self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
                
                // This is a little hack that causes our pageViewController to forget about other pages if there is a winnerMid.
                if let winnerMid = match["winnerMid"] {
                    self.pageViewController?.dataSource = nil
                    self.pageViewController?.dataSource = self.pageViewController
                }
                return
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier("matchSegue", sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "matchSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.mid = sender!.mid as Int
            tableViewController.knockoutTableViewController = self
        }
        else if (segue.identifier == "matchWinnerSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.mid = sender!["mid"] as Int
            tableViewController.match = sender!["match"] as [String:AnyObject]
            tableViewController.winnerChanged = true
            tableViewController.saveBarButton.enabled = true
            tableViewController.knockoutTableViewController = self            
        }
    }
    
    func setWinner(mid: Int, index: Int) {
        var match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
        if let participants = match["participants"] as? NSArray {
            let participantIndex = participants[index] as NSInteger
            match["winner"] = participantIndex
            self.performSegueWithIdentifier("matchWinnerSegue", sender: ["mid": mid, "match": match])
        }
    }
}
