//
//  NTAAboutViewController.swift
//  Tourney
//
//  Created by Joe Fender on 09/02/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAAboutViewController: UIViewController {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    @IBAction func supportButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://appbot.co/apps/ed075d36c8939001db5129951d676e559f76e227/faqs")!)
    }

    @IBAction func privacyPolicyAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.iubenda.com/privacy-policy/971919")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.aboutLabel.sizeToFit()
        self.copyrightLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
    }
}
