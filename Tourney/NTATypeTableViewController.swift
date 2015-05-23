//
//  NTATypeTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 27/11/2014.
//  Copyright (c) 2014 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTATypeTableViewController: UITableViewController {
    
    var tournament = PFObject(className: "Tournament")
    var selectedRow = NSIndexPath(forRow: 0, inSection: 0)
    
    @IBAction func nextAction(sender: AnyObject) {
        if (self.selectedRow.row == 0) {
            self.performSegueWithIdentifier("knockoutSegue", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Checks the default row
        self.tableView.cellForRowAtIndexPath(self.selectedRow)?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Uncomment these when we release groups
//        self.tableView.cellForRowAtIndexPath(self.selectedRow)?.accessoryType = .None
//        self.selectedRow = indexPath
//        self.tableView.cellForRowAtIndexPath(self.selectedRow)?.accessoryType = .Checkmark
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "knockoutSegue") {
            let viewController = segue.destinationViewController as! NTAKnockoutFormatTableViewController
            viewController.tournament = self.tournament
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.appLightColor()
        header.textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel.textColor = UIColor.appLightColor()
        footer.textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
}
