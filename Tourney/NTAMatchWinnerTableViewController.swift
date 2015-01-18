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
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
