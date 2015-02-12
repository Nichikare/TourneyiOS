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
    
    @IBOutlet weak var roundHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        
        if self.pageViewController?.roundCount == (self.pageIndex + 1) {
            self.roundHeaderLabel.text = "FINAL"
        }
        else {
            let roundSize = self.matches.count * 2
            self.roundHeaderLabel.text = "ROUND OF \(roundSize)"
        }
        self.roundHeaderLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
    
    // Number of matches in this round.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Hide the bronzeMatch if its disabled for the last round.
        if self.pageViewController?.roundCount == (self.pageIndex + 1) {
            if self.tournament["bronzeMatch"] as Bool == false {
                return self.matches.count - 1
            }
        }
        
        return self.matches.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let mid = self.matches[section]["mid"] {
            // If we're on the last round, append some useful terms.
            var append = ""
            if self.pageViewController?.roundCount == (self.pageIndex + 1) {
                if section == 1 {
                    append = " (3rd Place)"
                }
            }
            
            return "Match " + String(mid) + append
        }
        
        return ""
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30.0
        }
        
        return 50.0
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let mid = self.matches[section]["mid"] {
            let match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
            if let date = match["date"] as? NSDate {
                var formatString = NSDateFormatter.dateFormatFromTemplate("EdMMM jj:mm", options: 0, locale: NSLocale.currentLocale())
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = formatString
                
                return dateFormatter.stringFromDate(date)
            }
        }
        
        return ""
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.appLightColor()
        header.textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as UITableViewHeaderFooterView
        footer.textLabel.textColor = UIColor.appLightColor()
        footer.textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as NTAKnockoutMatchTableViewCell
        cell.delegate = self
        
        // Ensure elements are hidden by default.
        cell.winnerAButton.hidden = true
        cell.winnerBButton.hidden = true
        cell.scoreALabel.hidden = true
        cell.scoreBLabel.hidden = true
        cell.wonAImage.hidden = true
        cell.wonBImage.hidden = true
        
        // Default colors
        cell.nameALabel.textColor = UIColor.whiteColor()
        cell.nameBLabel.textColor = UIColor.whiteColor()
        cell.scoreALabel.textColor = UIColor.whiteColor()
        cell.scoreBLabel.textColor = UIColor.whiteColor()

        if let mid = self.matches[indexPath.section]["mid"] {
            // Save data to the cell.
            cell.mid = mid
            
            // Grab any match tournament data.
            let match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
            
            if let participants = match["participants"] as? NSArray {
                let indexA = participants[0] as Int
                let indexB = participants[1] as Int
                
                // Booleans to determine if a participant is set.
                var participantASet = false
                var participantBSet = false
                
                // TODO What if both -1? Can this happen?
                if indexA == -2 {
                    cell.nameALabel.text = "BYE"
                    cell.nameALabel.textColor = UIColor.appLightColor()
                }
                else if indexA == -1 {
                    cell.nameALabel.text = self.awaitingParticipantMessage(mid, weight: 0)
                    cell.nameALabel.textColor = UIColor.appLightColor()
                }
                else {
                    cell.nameALabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexA)
                    participantASet = true
                }
                
                if indexB == -2 {
                    cell.nameBLabel.text = "BYE"
                    cell.nameBLabel.textColor = UIColor.appLightColor()
                }
                else if indexB == -1 {
                    cell.nameBLabel.text = self.awaitingParticipantMessage(mid, weight: 1)
                    cell.nameBLabel.textColor = UIColor.appLightColor()
                }
                else {
                    cell.nameBLabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexB)
                    participantBSet = true
                }
                
                if let winner = match["winner"] as? Int {
                    if winner == indexA {
                        cell.nameALabel.textColor = UIColor.appGreenColor()
                        cell.scoreALabel.textColor = UIColor.appGreenColor()
                    }
                    else if winner == indexB {
                        cell.nameBLabel.textColor = UIColor.appGreenColor()
                        cell.scoreBLabel.textColor = UIColor.appGreenColor()
                    }

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
                    else {
                        if winner == indexA {
                            cell.wonAImage.hidden = false
                        }
                        else if winner == indexB {
                            cell.wonBImage.hidden = false
                        }
                    }
                }
                else if participantASet && participantBSet {
                    cell.winnerAButton.hidden = false
                    cell.winnerBButton.hidden = false
                }
            }
            else {
                cell.nameALabel.text = self.awaitingParticipantMessage(mid, weight: 0)
                cell.nameBLabel.text = self.awaitingParticipantMessage(mid, weight: 1)
                cell.nameALabel.textColor = UIColor.appLightColor()
                cell.nameBLabel.textColor = UIColor.appLightColor()
            }
        }

        return cell
    }
    
    func awaitingParticipantMessage(mid: Int, weight: Int) -> String {
        if let previousMatches = self.pageViewController?.map.filter({$0["winnerMid"] == mid && $0["winnerWeight"] == weight || $0["loserMid"] == mid && $0["loserWeight"] == weight}) {
            for match in previousMatches {
                if let matchMid = match["mid"] {
                    let midString = String(matchMid)
                    if match["winnerMid"] == mid {
                        return "Winner from match \(midString)"
                    }
                    else {
                        return "Loser from match \(midString)"
                    }
                }
            }
        }
        
        return ""
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
