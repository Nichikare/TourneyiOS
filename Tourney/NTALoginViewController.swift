//
//  NTALoginViewController.swift
//  Tourney
//
//  Created by Joe Fender on 29/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTALoginViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if PFUser.currentUser() == nil {
//            PFUser.enableAutomaticUser()
//            PFUser.currentUser().saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
//                if succeeded {
//                    self.goToNavigationController()
//                } else {
//                    self.label.text = "Error occurred. Internet access is required for the first run of Tourney. Please close the app and try again."
//                }
//            })
//        }
//        else {
//            self.goToNavigationController()
//        }
        
        if PFUser.currentUser() == nil {
            PFUser.enableAutomaticUser()
        }

        PFUser.currentUser().saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
            if succeeded {
                // TODO succeeds even if not connected.
                self.goToNavigationController()
            } else {
                self.label.text = "You are not connected to the internet. Please check your network connection and try again."
            }
        })
    }
    
    func goToNavigationController() {
        // Switch to navigation controller.
        self.appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InitialNavigationController") as? UIViewController
        self.appDelegate.initialViewController = self.appDelegate.window?.rootViewController
    }

}
