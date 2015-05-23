//
//  NTATournamentListTableViewController.swift
//  TournamentApp
//
//  Created by Joe Fender on 09/11/2014.
//  Copyright (c) 2014 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTATournamentListTableViewController: UITableViewController {
    
    @IBAction func unwindToList (segue : UIStoryboardSegue) {}
    
    var tournaments = [AnyObject]();
    var selectedRow: Int = 0
    
    @IBAction func refreshTable(sender: UIRefreshControl) {
        // Attempt to load tournaments from Parse. If successful, overwrite any existing data.
        self.loadTournaments(false, success: {(tournaments) in
            self.tournaments = tournaments;
            self.tableView.reloadData()
            sender.endRefreshing()
        }, fail: {() in
            sender.endRefreshing()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensures the table is up to date with any changes that happened elsewhere.
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any tournaments that have been pinned to the LDS.
        self.loadTournaments(true, success: {(tournaments) in
            self.tournaments = tournaments;
            self.tableView.reloadData()
        }, fail: {})
        
        // Attempt to load tournaments from Parse. If successful, overwrite any existing data.
        self.loadTournaments(false, success: {(tournaments) in
            self.tournaments = tournaments;
            self.tableView.reloadData()
        }, fail: {})
    }
    
    func loadTournaments(fromLocalDatastore: Bool, success: (tournaments: [AnyObject]!) -> Void, fail: () -> Void) {
        var query = PFQuery(className:"Tournament")
        query.orderByAscending("createdAt")
        query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
        
        if fromLocalDatastore {
            query.fromLocalDatastore()
        }
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if (error == nil) {
                success(tournaments: objects)
            } else {
                NSLog("Error: %@ %@", error!, error!.userInfo!)
                fail()
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tournaments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.tournaments[indexPath.row]["title"] as? String
        if let type = self.tournaments[indexPath.row]["type"] as? NSString {
            cell.detailTextLabel?.text = type.capitalizedString
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // This must be left empty for swipable rows to work.
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var editRowAction = UITableViewRowAction(style: .Normal, title: "Edit", handler:{action, index in
            self.selectedRow = indexPath.row
            self.performSegueWithIdentifier("editSegue", sender: indexPath)
        })
        
        var deleteRowAction = UITableViewRowAction(style: .Default, title: "Delete", handler:{action, index in
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let destroyAction = UIAlertAction(title: "Delete Tournament", style: .Destructive) { (action) in
                let tournament = self.tournaments[index.row] as! PFObject
                tournament.deleteEventually()
                self.tournaments.removeAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Automatic)
            }
            alertController.addAction(destroyAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                self.tableView.editing = false
                self.tableView.cellForRowAtIndexPath(index)?.editing = false
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
        
        editRowAction.backgroundColor = UIColor.appLightColor()
        deleteRowAction.backgroundColor = UIColor.appRedColor()
        
        return [deleteRowAction, editRowAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        
        let tournament = self.tournaments[indexPath.row] as! PFObject
        if (tournament["type"] == nil || tournament["type"] as! String == "") {
            self.performSegueWithIdentifier("participantSegue", sender: tournament)
        }
        else {
            self.performSegueWithIdentifier("tournamentSegue", sender: tournament)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "newSegue") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var tableViewController = navigationController.topViewController as! NTATNameTableViewController
            tableViewController.createNewTournament = true
        }
        else if (segue.identifier == "participantSegue") {
            let viewController = segue.destinationViewController as! NTAParticipantsTableViewController
            viewController.tournament = sender as! PFObject
        }
        else if (segue.identifier == "tournamentSegue") {
            var pageViewController = segue.destinationViewController as! NTAKnockoutPageViewController
            pageViewController.tournament = sender as! PFObject
        }
        else if (segue.identifier == "editSegue") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var tableViewController = navigationController.topViewController as! NTAEditTournamentTableViewController
            let indexPath = sender as! NSIndexPath
            tableViewController.tournament = self.tournaments[indexPath.row] as! PFObject
        }
    }
}