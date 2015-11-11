//
//  NTAGroupPlacementsTableViewController.swift
//  Tourney
//
//  Created by Joe Fender on 27/08/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAGroupPlacementsTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var picker : UIPickerView = UIPickerView.alloc()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var tournament = PFObject(className: "Tournament")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Placements"
        
        picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        var button = UIBarButtonItem(title: "Start", style: .Done, target: self, action: "startTournament:")
        self.navigationItem.rightBarButtonItem = button
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.tournament["groupCount"] as! Int
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "Text"
    }
    
    func startTournament(sender: UIBarButtonItem) {
        // TODO: Create matches
        var matches: [String:[String:AnyObject]] = [:]
        
        // $count = count($positions);
        
        // Add a dummy position for odd groups
        //        if ($count % 2) {
        //            $positions[] = 0;
        //            $count++;
        //        }
        // n-1 rounds
        //        $rounds = range(1, ($count-1) * $node->format);
        //
        //        // n/2 matches per round
        //        $match_count = $count / 2;
        //
        //        // Create matches for each round
        //        foreach ($rounds as $round) {
        //            $positions_tmp = $positions;
        //
        //            for ($i=0;$i<$match_count;$i++) {
        //                // Pick 2 competitors
        //                $a = array_shift($positions_tmp);
        //                $b = array_pop($positions_tmp);
        //
        //                // Only create matches without dummy competitors
        //                if ($a && $b) {
        //                    // Initialize the match
        //                    $match = array(
        //                        'round' => $round,
        //                        'competitors' => array($a, $b),
        //                    );
        //
        //                    // Reverse competitors on even rounds to ensure home/away fairness
        //                    if ($round % 2 == 0) {
        //                        $match['competitors'] = array_reverse($match['competitors']);
        //                    }
        //
        //                    $matches[] = $match;
        //                }
        //            }
        //
        //            // Move the last id from competitors after the first
        //            $position = array_pop($positions);
        //            array_splice($positions, 1, 0, $position);
        //        }
        
        //        TODO: Loop through all matches
        //        var participants: [Int] = [-1, -1]
        //        participants[0] = indexA
        //        participants[1] = indexB
        //        matches[String(mid)] = ["participants": participants]
        //        TODO: Set winner for BYEs
        //        matches[String(mid)]?.updateValue(indexB, forKey: "winner")
        
        // Save match records.
        self.tournament.setObject(matches, forKey: "matches")
        self.tournament.saveEventually()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let navigationController = self.appDelegate.initialViewController as! UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
        let viewController = navigationController.topViewController as! NTATournamentListTableViewController
        viewController.performSegueWithIdentifier("tournamentSegue", sender: self.tournament)
    }

    // TODO: Store entered group in self.tournaments["participants"] property.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! UITableViewCell
        
        let position = String(indexPath.row + 1)
        let positionLength = count(position) + 1
        let participant = self.tournament["participants"]!.objectAtIndex(indexPath.row) as! NSDictionary
        let name = participant["name"] as! String
        
        var attributedString = NSMutableAttributedString(string: position + ". " + name)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.appLightColor(), range: NSMakeRange(0, positionLength))
        
        cell.textLabel?.attributedText = attributedString
        cell.backgroundColor = UIColor.clearColor()
        
        let cellTextField = UITextField(frame: CGRectZero)
        cellTextField.delegate = self
        cellTextField.enabled = false
        cellTextField.text = "1"
        cellTextField.inputView = picker
        cellTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        cellTextField.textAlignment = NSTextAlignment.Right
        cellTextField.sizeToFit()
        cell.accessoryView = cellTextField
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let participantCount = self.tournament["participants"]!.count
        return participantCount
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.enabled = false
        let cell = textField.superview as! UITableViewCell
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                textField.text = String(1)
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
    
}
