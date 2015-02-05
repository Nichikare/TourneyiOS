//
//  NTAScoresTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 25/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAScoresTableViewController: UITableViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var tournament = PFObject(className: "Tournament")
    var match = [String:AnyObject]()
    var delegate: NTAMatchTableViewControllerDelegate?
    var setCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if var scores = self.match["scores"] as? NSArray {
            if scores.count > 0 {
                self.setCount = scores.count
            }
        }
        else {
            self.match["scores"] = []
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.setCount + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        default:
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section > 0) {
            return "Set \(section)"
        }
        
        return ""
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 0) {
            return "Sets allow you to create multiple groups of scores."
        }
        
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as NTAScoresTableViewCell
        cell.cellTextField.delegate = self
        cell.cellTextField.enabled = false
        
        if (indexPath.section == 0) {
            cell.textLabel?.text = "\(String(self.setCount)) sets"
            cell.cellTextField.hidden = true
            var setStepper = UIStepper(frame: CGRectZero)
            setStepper.minimumValue = 0
            setStepper.maximumValue = 99
            setStepper.autorepeat = false
            setStepper.value = Double(self.setCount)
            setStepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            cell.accessoryView = setStepper
        }
        else {
            cell.accessoryView = nil
            cell.cellTextField.hidden = false
            if let participants = self.match["participants"] as? NSArray {
                let index = participants[indexPath.row] as NSInteger
                cell.textLabel?.text = self.appDelegate.getParticipantNameFromIndex(self.tournament, index: index)
                
                if let scores = self.match["scores"] as? [[Int]] {
                    let score = scores[indexPath.section - 1][indexPath.row]
                    cell.cellTextField.text = String(score)
                }
                else {
                    cell.cellTextField.text = String(0)
                }
            }
        }
        
        return cell
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.enabled = false
        let textFieldCenter = textField.center
        let pointInTableView = tableView.convertPoint(textFieldCenter, fromView: textField.superview?.superview)

        if let indexPath = self.tableView.indexPathForRowAtPoint(pointInTableView) {
            if var scores = self.match["scores"] as? [[Int]] {
                var set = scores[indexPath.section - 1]
                if let value = textField.text.toInt() {
                    set[indexPath.row] = value
                }
                else {
                    set[indexPath.row] = 0
                    textField.text = String(0)
                }
                
                scores[indexPath.section - 1] = set
                self.match["scores"] = scores
            }
            
            self.delegate?.updateValue("scores", toValue: self.match["scores"] as [[Int]])
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text.toInt() == 0 {
           textField.text = ""
        }
    }
    
    func stepperValueChanged(sender: UIStepper!) {
        let newSetCount = Int(sender.value)
        if var scores = self.match["scores"] as? [[Int]] {
            if (newSetCount > self.setCount) {
                scores.append([0, 0])
            }
            else {
                scores.removeLast()
            }
            
            self.match["scores"] = scores
            self.delegate?.updateValue("scores", toValue: self.match["scores"] as [[Int]])
        }
        self.setCount = newSetCount
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as NTAScoresTableViewCell
        cell.cellTextField.enabled = true
        cell.cellTextField.becomeFirstResponder()
    }
}
