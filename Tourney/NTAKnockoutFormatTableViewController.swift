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
        // TODO this may be run multiple times so check previous set value if any?
        extraMatchSwitch.on = false
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
        self.tournament.saveEventually()
        
        let matches = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["round"] == 1})
        var firstRoundMatches: [String:[String:AnyObject]] = [:]
        // TODO use correct pager id
        for match in matches {
            if let mid = match["mid"] {
                var participants: NSMutableArray = []
                
                let indexA = match["indexA"]! as NSInteger
                if self.tournament["participants"].count > indexA {
                    participants[0] = indexA
                }
                else {
                    participants[0] = -1
                }
                
                let indexB = match["indexB"]! as NSInteger
                if self.tournament["participants"].count > indexB {
                    participants[1] = indexB
                }
                else {
                    participants[1] = -1
                }

                firstRoundMatches[String(mid)] = ["participants": participants]
            }
        }
        self.tournament["matches"] = firstRoundMatches
        self.tournament.saveEventually()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let navigationController = self.appDelegate.initialViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Checks the default rows
        self.tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .Checkmark
        self.tableView.cellForRowAtIndexPath(selectedPlacementRow)?.accessoryType = .Checkmark
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0:
            tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .None
            selectedFormatRow = indexPath
            tableView.cellForRowAtIndexPath(selectedFormatRow)?.accessoryType = .Checkmark
            break
            
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
