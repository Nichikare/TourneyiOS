//
//  NTAGroupsSettingsTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 19/06/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAGroupsSettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var groupCountCell: UITableViewCell!
    @IBOutlet weak var winPointsCell: UITableViewCell!
    @IBOutlet weak var drawPointsCell: UITableViewCell!
    @IBOutlet weak var lossPointsCell: UITableViewCell!
    @IBOutlet weak var loopCountCell: UITableViewCell!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var tournament = PFObject(className: "Tournament")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Groups"
        
        var button = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "placements:")
        self.navigationItem.rightBarButtonItem = button
        
        textFieldAccessoryView(self.groupCountCell, value: String(1))
        textFieldAccessoryView(self.winPointsCell, value: String(3))
        textFieldAccessoryView(self.drawPointsCell, value: String(1))
        textFieldAccessoryView(self.lossPointsCell, value: String(0))
        textFieldAccessoryView(self.loopCountCell, value: String(1))
    }
    
    func textFieldAccessoryView(cell: UITableViewCell, value: String) {
        let cellTextField = UITextField(frame: CGRectZero)
        cellTextField.delegate = self
        cellTextField.enabled = false
        cellTextField.text = value
        cellTextField.keyboardType = UIKeyboardType.NumberPad
        cellTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        cellTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        cellTextField.textAlignment = NSTextAlignment.Right
        cellTextField.sizeToFit()
        cell.accessoryView = cellTextField
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    func placements(sender: UIBarButtonItem) {
        self.tournament["type"] = "groups"
        
        let groupCountTextField = self.groupCountCell.accessoryView as! UITextField
        if let value = groupCountTextField.text.toInt() {
            self.tournament["groupCount"] = value
        }
        
        let winPointsTextField = self.winPointsCell.accessoryView as! UITextField
        if let value = winPointsTextField.text.toInt() {
            self.tournament["winPoints"] = value
        }
        
        let drawPointsTextField = self.drawPointsCell.accessoryView as! UITextField
        if let value = drawPointsTextField.text.toInt() {
            self.tournament["drawPoints"] = value
        }
        
        let lossPointsTextField = self.lossPointsCell.accessoryView as! UITextField
        if let value = lossPointsTextField.text.toInt() {
            self.tournament["lossPoints"] = value
        }
        
        let loopCountTextField = self.loopCountCell.accessoryView as! UITextField
        if let value = loopCountTextField.text.toInt() {
            self.tournament["loopCount"] = value
        }
        
        self.performSegueWithIdentifier("placementsSegue", sender: self)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.enabled = false
        let cell = textField.superview as! UITableViewCell
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                if (cell.textLabel?.text == "Number of Groups") {
                    textField.text = String(1)
                }
                else if (cell.textLabel?.text == "Win") {
                    textField.text = String(3)
                }
                else if (cell.textLabel?.text == "Draw") {
                    textField.text = String(1)
                }
                else if (cell.textLabel?.text == "Loss") {
                    textField.text = String(0)
                }
                else if (cell.textLabel?.text == "Loops") {
                    textField.text = String(1)
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidChange(textField: UITextField) {
        textField.sizeToFit()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let cellTextField = cell?.accessoryView as! UITextField
        cellTextField.enabled = true
        cellTextField.becomeFirstResponder()
        self.tableView.scrollToNearestSelectedRowAtScrollPosition(UITableViewScrollPosition.Middle, animated: true)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "placementsSegue") {
            let viewController = segue.destinationViewController as! NTAGroupPlacementsTableViewController
            viewController.tournament = self.tournament
        }
    }
}
