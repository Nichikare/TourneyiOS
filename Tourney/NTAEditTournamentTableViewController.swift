//
//  NTAEditTournamentTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 21/11/2014.
//  Copyright (c) 2014 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAEditTournamentTableViewController: UITableViewController {
    
    var tournament = PFObject(className: "Tournament")
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nameLabel.text = self.tournament["title"] as NSString
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) {
            return 0
        }
        else {
            return super.tableView(self.tableView, numberOfRowsInSection:section)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let textLabel = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
        if (textLabel == "Reset" || textLabel == "Delete") {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            if (textLabel == "Reset") {
                alertController.message = "Are you sure? All tournament matches will be deleted."
                
                let destroyAction = UIAlertAction(title: "Reset Tournament", style: .Destructive) { (action) in
                    println(action)
                }
                alertController.addAction(destroyAction)
            }
            else {
                let destroyAction = UIAlertAction(title: "Delete Tournament", style: .Destructive) { (action) in
                    println(action)
                }
                alertController.addAction(destroyAction)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "nameSegue") {
            let tableViewController = segue.destinationViewController as NTATNameTableViewController
            tableViewController.tournament = self.tournament
        }
    }
}
