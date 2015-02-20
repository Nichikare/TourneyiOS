//
//  NTAKnockoutFormatTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 18/11/2014.
//  Copyright (c) 2014 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAKnockoutFormatTableViewController: UITableViewController {

    @IBOutlet weak var extraMatchCell: UITableViewCell!
    @IBOutlet weak var sizeCell: UITableViewCell!
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var tournament = PFObject(className: "Tournament")
    
    var selectedFormatRow = NSIndexPath(forRow: 0, inSection: 0)
    var selectedPlacementRow = NSIndexPath(forRow: 0, inSection: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Knockout"
        
        var button = UIBarButtonItem(title: "Start", style: .Done, target: self, action: "startTournament:")
        self.navigationItem.rightBarButtonItem = button
        
        var extraMatchSwitch = UISwitch(frame: CGRectZero) as UISwitch
        extraMatchSwitch.on = false
        extraMatchSwitch.onTintColor = UIColor.appBlueColor()
        extraMatchSwitch.tintColor = UIColor.appLightColor()
        extraMatchCell.accessoryView = extraMatchSwitch
    }
    
    func startTournament(sender: UIBarButtonItem) {
        self.tournament["type"] = "knockout"
        if (self.selectedFormatRow.row == 0) {
            self.tournament["format"] = "single"
        }
        else {
            self.tournament["format"] = "double"
        }
        
        let extraMatchSwitch = self.extraMatchCell.accessoryView as UISwitch
        self.tournament["bronzeMatch"] = extraMatchSwitch.on
        
        // Store byes to advance.
        var byes: [[String:Int]] = []
        
        // Grab the first round match info to determine seeding.
        var firstRoundMatches = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["round"] == 1})
        
        // Loop through match info and apply seeds to tournament.
        var matches: [String:[String:AnyObject]] = [:]
        for matchInfo in firstRoundMatches {
            if let mid = matchInfo["mid"] {
                var participants: [Int] = [-1, -1]
                
                let indexA = matchInfo["indexA"]! as Int
                let indexB = matchInfo["indexB"]! as Int
                
                if self.tournament["participants"].count > indexA {
                    participants[0] = indexA
                }
                else {
                    participants[0] = -2
                }
                
                if self.tournament["participants"].count > indexB {
                    participants[1] = indexB
                }
                else {
                    participants[1] = -2
                }
                
                matches[String(mid)] = ["participants": participants]
                
                // Auto-advance BYEs.
                if participants[0] == -2 {
                    matches[String(mid)]?.updateValue(indexB, forKey: "winner")
                    byes.append(["index": participants[1], "mid": matchInfo["winnerMid"]! as Int, "weight": matchInfo["winnerWeight"]! as Int])
                }
                else if participants[1] == -2 {
                    matches[String(mid)]?.updateValue(indexA, forKey: "winner")
                    byes.append(["index": participants[0], "mid": matchInfo["winnerMid"]! as Int, "weight": matchInfo["winnerWeight"]! as Int])
                }
            }
        }
        
        
        // Save match records.
        self.tournament.setObject(matches, forKey: "matches")
        
        // TODO: Make another pass at round 2 matches to check for more auto-advance BYEs. (DE)
        // Advance participants for BYEs.
        for bye in byes {
            self.appDelegate.advanceKnockoutParticipant(self.tournament, participantIndex: bye["index"]!, nextMid: bye["mid"]!, nextWeight: bye["weight"]!)
        }

        self.tournament.saveEventually()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let navigationController = self.appDelegate.initialViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
        let viewController = navigationController.topViewController as NTATournamentListTableViewController
        viewController.performSegueWithIdentifier("tournamentSegue", sender: self.tournament)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Checks the default rows
        self.tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .Checkmark
        self.tableView.cellForRowAtIndexPath(selectedPlacementRow)?.accessoryType = .Checkmark
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        
        return super.tableView(tableView, titleForFooterInSection: section)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0:
            // TODO: Uncomment when we release double elimination.
//            tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .None
//            selectedFormatRow = indexPath
//            tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .Checkmark
            break
            
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
    
    
}
