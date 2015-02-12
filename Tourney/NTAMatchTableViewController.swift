//
//  NTAMatchTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

protocol NTAMatchTableViewControllerDelegate {
    func getValue(key: String) -> AnyObject
    func updateValue(key: String, toValue: AnyObject)
    func resetWinner()
}

class NTAMatchTableViewController: UITableViewController, NTAMatchTableViewControllerDelegate, UITextViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var knockoutTableViewController: NTAKnockoutTableViewController?
    var tournament = PFObject(className: "Tournament")
    var mid = 0
    var match = [String:AnyObject]()
    
    // Set this to true to perform progression actions on save
    var winnerChanged: Bool = false
    
    // Determines if the date picker should be shown
    var editingDate: Bool = false
    
    @IBOutlet weak var winnerTableCell: UITableViewCell!
    @IBOutlet weak var scoresTableCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var clearDateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Match \(self.mid)"
        
        // This allows us to pass in altered match objects
        if self.match.isEmpty {
            self.match = self.appDelegate.getTournamentMatch(self.tournament, mid: self.mid)
        }
        
        // Set initial date
        if (self.match["date"] != nil) {
            self.updateDateCellDetailText(self.match["date"] as NSDate)
        }
        
        // Remove notes text view padding.
        self.notesTextView.textContainer.lineFragmentPadding = 0
        self.notesTextView.textContainerInset = UIEdgeInsetsZero
        self.notesTextView.delegate = self
        
        if let notes = self.match["notes"] as? NSString {
            self.notesTextView.text = notes
            if (self.notesTextView.text == "") {
                self.notesTextView.text = "Notes"
                self.notesTextView.textColor = UIColor.appLightColor()
            }
            else {
                self.notesTextView.textColor = UIColor.whiteColor()
            }
        }
        
        let barButtonItemFont = UIFont(name: "AvenirNext-DemiBold", size: 16)
        if let font = barButtonItemFont {
            self.saveBarButton.setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set elements to default states.
        self.winnerTableCell.detailTextLabel?.text = "None"
        self.winnerTableCell.detailTextLabel?.textColor = UIColor.appLightColor()
        self.scoresTableCell.detailTextLabel?.text = "None"
        self.scoresTableCell.detailTextLabel?.textColor = UIColor.appLightColor()
        self.scoresTableCell.textLabel?.enabled = false
        
        if let participants = self.match["participants"] as? [Int] {
            if participants[0] > -1 && participants[1] > -1 {
                self.winnerTableCell.textLabel?.enabled = true
            }
            
            if participants[0] == -2 || participants[1] == -2 {
                self.winnerTableCell.textLabel?.enabled = true
                self.scoresTableCell.textLabel?.enabled = true
                self.winnerTableCell.accessoryType = UITableViewCellAccessoryType.None
                self.scoresTableCell.accessoryType = UITableViewCellAccessoryType.None
            }
            
            if let winnerIndex = self.match["winner"] as? Int {
                let winnerName = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: winnerIndex)
                self.winnerTableCell.detailTextLabel?.text = winnerName
                self.winnerTableCell.detailTextLabel?.textColor = UIColor.whiteColor()
                self.winnerTableCell.textLabel?.enabled = true
                self.scoresTableCell.textLabel?.enabled = true
            }
        }
    
        if let scores = self.match["scores"] as? [[Int]] {
            if scores.count > 0 {
                var scoreStrings: [String] = []
                for set in scores {
                    scoreStrings.append("\(String(set[0]))-\(String(set[1]))")
                }
                self.scoresTableCell.detailTextLabel?.text = ", ".join(scoreStrings)
                self.scoresTableCell.detailTextLabel?.textColor = UIColor.whiteColor()
            }
        }
    }

    @IBAction func saveAction(sender: AnyObject) {
        // Check for changes to the match notes.
        if let notes = self.match["notes"] as? NSString {
            if self.notesTextView.text != notes {
                if self.notesTextView.text == "Notes" {
                    self.match["notes"] = ""
                }
                else {
                    self.match["notes"] = self.notesTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                }
            }
        }
        else if self.notesTextView.text != "Notes" && self.notesTextView.text != "" {
            self.match["notes"] = self.notesTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
        self.appDelegate.updateTournamentMatch(self.tournament, mid: self.mid, match: self.match)
        
        // Advance participants if the winner has been changed.
        if winnerChanged == true {
            if self.tournament["type"] as NSString == "knockout" {
                let participants = self.match["participants"] as [Int]
                let winnerIndex = self.match["winner"] as Int
                let loserIndex = winnerIndex == participants[0] ? participants[1] : participants[0]
                
                let matchInfo = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["mid"] == self.mid})[0] as [String:Int]
                
                // Advance winner.
                if let winnerMid = matchInfo["winnerMid"] {
                    if let winnerWeight = matchInfo["winnerWeight"] {
                        self.appDelegate.advanceKnockoutParticipant(self.tournament, participantIndex: winnerIndex, nextMid: winnerMid, nextWeight: winnerWeight)
                    }
                }
                
                // Advance loser.
                if let loserMid = matchInfo["loserMid"] {
                    if let loserWeight = matchInfo["loserWeight"] {
                        self.appDelegate.advanceKnockoutParticipant(self.tournament, participantIndex: loserIndex, nextMid: loserMid, nextWeight: loserWeight)
                    }
                }
            }
        }
        
        self.tournament.saveEventually()
        self.navigationController?.popViewControllerAnimated(true)        
        self.knockoutTableViewController?.refreshMatch(self.mid)
    }
    
    @IBAction func clearDate(sender: AnyObject) {
        tableView.beginUpdates()
        self.editingDate = false
        self.match["date"] = nil
        self.dateCell.detailTextLabel?.text = "None"
        self.dateCell.detailTextLabel?.textColor = UIColor.appLightColor()
        self.clearDateButton.hidden = true
        self.saveBarButton.enabled = true
        tableView.endUpdates()
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        self.match["date"] = sender.date
        self.updateDateCellDetailText(sender.date)
        self.saveBarButton.enabled = true
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = "myString"
        return NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func updateDateCellDetailText(date: NSDate) {
        var formatString = NSDateFormatter.dateFormatFromTemplate("EdMMM jj:mm", options: 0, locale: NSLocale.currentLocale())
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        
        self.dateCell.detailTextLabel?.text = dateFormatter.stringFromDate(date)
        self.dateCell.detailTextLabel?.textColor = UIColor.whiteColor()
        self.clearDateButton.hidden = false
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.textColor = UIColor.whiteColor()
        if (textView.text == "Notes") {
            textView.text = ""
        }
        
        self.saveBarButton.enabled = true
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Notes"
            textView.textColor = UIColor.appLightColor()
        }
        
        if let notes = self.match["notes"] as? NSString {
            if self.notesTextView.text != notes {
                self.saveBarButton.enabled = true
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 1) { // Picker cell
            if !self.editingDate {
                return 0
            }
        }

        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1 || indexPath.row != 2) {
            self.notesTextView.resignFirstResponder()
        }
        
        if (indexPath.section == 1 && indexPath.row == 0) { // Date cell
            tableView.beginUpdates()
            self.editingDate = !self.editingDate
            tableView.endUpdates()
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "winnerSegue" {
            self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true)
            
            if let participants = self.match["participants"] as? [Int] {
                // Only allow a winner to be set when both participants are available.
                if participants[0] == -1 || participants[1] == -1 {
                    let winnerAlertController = UIAlertController(title: nil, message: "There must be 2 match participants before you can set a winner.", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    winnerAlertController.addAction(OKAction)
                    self.presentViewController(winnerAlertController, animated: true, completion: nil)
                    return false
                }
                else if participants[0] == -2 || participants[1] == -2 {
                    return false
                }
            }
        }
        else if identifier == "scoresSegue" {
            self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true)
            
            if let winnerIndex = self.match["winner"] as? Int {
                // Allow score entry when there are no BYEs.
                if let participants = self.match["participants"] as? [Int] {
                    return participants[0] != -2 && participants[1] != -2
                }
            }

            let scoreAlertController = UIAlertController(title: nil, message: "A winner must be set before you can enter scores.", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            scoreAlertController.addAction(OKAction)
            self.presentViewController(scoreAlertController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "winnerSegue") {
            let tableViewController = segue.destinationViewController as NTAMatchWinnerTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.match = self.match
            tableViewController.mid = self.mid
            tableViewController.delegate = self
        }
        else if (segue.identifier == "scoresSegue") {
            let tableViewController = segue.destinationViewController as NTAScoresTableViewController
            tableViewController.tournament = self.tournament
            tableViewController.match = self.match
            tableViewController.delegate = self
        }
    }
    
    // Delegate function to get the original match data.
    func getValue(key: String) -> AnyObject {
        var originalMatch = self.appDelegate.getTournamentMatch(self.tournament, mid: self.mid)
        if let value: AnyObject = originalMatch[key] {
            return value
        }
        
        return NSNull()
    }
    
    // Delegate function to update local match data.
    func updateValue(key: String, toValue: AnyObject) {
        self.match[key] = toValue
        
        if (key == "winner") {
            self.winnerChanged = true
        }
        
        self.saveBarButton.enabled = true
    }
    
    // Delegate function to delete the current and subsequent match winners.
    func resetWinner() {
        self.match.removeValueForKey("winner")
        self.match.removeValueForKey("scores")
        self.appDelegate.updateTournamentMatch(self.tournament, mid: self.mid, match: self.match)
        self.knockoutTableViewController?.refreshMatch(self.mid)
        
        // Reset any next matches.
        let matchInfo = self.appDelegate.getKnockoutMap(self.tournament).filter({$0["mid"] == self.mid})[0] as [String:Int]
        if let winnerMid = matchInfo["winnerMid"] {
            if let winnerWeight = matchInfo["winnerWeight"] {
                self.appDelegate.advanceKnockoutParticipant(self.tournament, participantIndex: -1, nextMid: winnerMid, nextWeight: winnerWeight)
            }
        }
        if let loserMid = matchInfo["loserMid"] {
            if let loserWeight = matchInfo["loserWeight"] {
                self.appDelegate.advanceKnockoutParticipant(self.tournament, participantIndex: -1, nextMid: loserMid, nextWeight: loserWeight)
            }
        }
        
        self.tournament.saveEventually()
    }
}
