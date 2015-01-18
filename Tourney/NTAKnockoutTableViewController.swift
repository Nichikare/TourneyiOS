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
    var tournament = PFObject(className: "Tournament")
    var matches = [[String:Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO use correct round number from pager
        self.matches = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["round"] == 1})
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.tournament["title"] as NSString
    }
    
    @IBAction func showActionSheet(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let editAction = UIAlertAction(title: "Edit", style: .Default) { (action) in
            self.performSegueWithIdentifier("editSegue", sender: self)
        }
        alertController.addAction(editAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Number of matches in this round.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO use current pager ID
        return self.matches.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let match = section + 1
        return "Match " + String(match)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as NTAKnockoutMatchTableViewCell
        cell.delegate = self

        // TODO use current pager ID and find by round
        if let mid = self.matches[indexPath.section]["mid"] {
            // Save data to the cell.
            cell.mid = mid
            
            let match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
            if let participants = match["participants"] as? NSArray {
                let indexA = participants[0] as NSInteger
                let indexB = participants[1] as NSInteger
                
                // TODO What if both -1? Can this happen?
                if indexA == -1 {
                    cell.nameALabel.text = "BYE"
                }
                else {
                    cell.nameALabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexA)
                }
                
                if indexB == -1 {
                    cell.nameBLabel.text = "BYE"
                }
                else {
                    cell.nameBLabel.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: indexB)
                }
            }
        }

        return cell
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
        }
        else if (segue.identifier == "matchWinnerSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.mid = sender!["mid"] as Int
            tableViewController.match = sender!["match"] as [String:AnyObject]
            tableViewController.winnerChanged = true
            tableViewController.saveBarButton.enabled = true
        }
        else if (segue.identifier == "editSegue") {
            let navigationController = segue.destinationViewController as UINavigationController
            var tableViewController = navigationController.topViewController as NTAEditTournamentTableViewController
            tableViewController.tournament = self.tournament
        }
    }
    
    func setWinner(mid: Int, index: Int) {
        var match = self.appDelegate.getTournamentMatch(self.tournament, mid: mid)
        if let participants = match["participants"] as? NSArray {
            let indexA = participants[index] as NSInteger
            match["winner"] = indexA
            self.performSegueWithIdentifier("matchWinnerSegue", sender: ["mid": mid, "match": match])
        }
    }
}
