//
//  AppDelegate.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var initialViewController: UIViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // TODO make this async?
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId("4zjfhYhbjTMD58b8IXsxjrEsR0xzyUsIIkJkzZ5r", clientKey: "1ZSLFOheFZwo2AjsbGngDGfBClkUOLfJvS6Nxx1b")
        self.initialViewController = self.window?.rootViewController
        
        // Set default navigation bar colors.
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().barTintColor = UIColor.appBackgroundColor()
        UINavigationBar.appearance().tintColor =  UIColor.appBlueColor()
        UINavigationBar.appearance().translucent = false
        
        UIToolbar.appearance().barTintColor = UIColor.appLightBackgroundColor()
        UIToolbar.appearance().tintColor = UIColor.appBlueColor()
        
        // Table colors.
        UITableView.appearance().backgroundColor = UIColor.appBackgroundColor()
        UITableView.appearance().separatorColor = UIColor.appSeparatorColor()
        UITableViewCell.appearance().backgroundColor = UIColor.appLightBackgroundColor()
        UITableViewCell.appearance().tintColor = UIColor.appLightColor()
        UITableViewCell.appearance().textLabel?.textColor = UIColor.whiteColor()
        UITableViewCell.appearance().detailTextLabel?.textColor = UIColor.appLightColor()
        
        let colorView = UIView()
        colorView.backgroundColor = UIColor.appSelectedColor()
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        // Button colors.
        UIBarButtonItem.appearance().tintColor = UIColor.appBlueColor()
        self.window?.tintColor = UIColor.appBlueColor()
        UIApplication.sharedApplication().keyWindow?.tintColor = UIColor.appBlueColor()
        UIButton.appearance().tintColor = UIColor.appBlueColor()
        
        // Textfield colors.
        UITextField.appearance().textColor = UIColor.whiteColor()
        
        // Fonts
        let navigationBarFont = UIFont(name: "AvenirNext-Regular", size: 16)
        if let font = navigationBarFont {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font]
        }
        
        let barButtonItemFont = UIFont(name: "AvenirNext-Regular", size: 16)
        if let font = barButtonItemFont {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        UILabel.appearance().font = UIFont(name: "AvenirNext-Regular", size: 16)
        UITextField.appearance().font = UIFont(name: "AvenirNext-Regular", size: 16)
        
        return true
    }
    
    func getKnockoutMapSize(tournament: PFObject) -> Double {
        let participantCount = tournament["participants"].count as Int
        let logParticipantCount = log(Double(participantCount))
        let logMultiple = log(Double(2))
        let size = pow(2, ceil(logParticipantCount/logMultiple))
        return size
    }
    
    func getKnockoutMap(tournament: PFObject) -> [[String:Int]] {
        let size = self.getKnockoutMapSize(tournament)
        let plist = "knockout_single_\(Int(size))"

        if let path = NSBundle.mainBundle().pathForResource(plist, ofType: "plist") {
            if let map = NSDictionary(contentsOfFile: path) {
                if let matches = map["matches"] as? [[String:Int]] {
                    return matches
                }
            }
        }
        
        // This should never be hit but here just incase.
        return []
    }
    
    // Helper function to advance a participant to a given match and weight.
    func advanceKnockoutParticipant(tournament: PFObject, participantIndex: Int, nextMid: Int, nextWeight: Int) {
        var nextMatch = self.getTournamentMatch(tournament, mid: nextMid)
        if nextMatch.isEmpty {
            nextMatch["participants"] = [-1, -1]
        }
        var participants = nextMatch["participants"] as [Int]
        participants[nextWeight] = participantIndex
        nextMatch["participants"] = participants
        self.updateTournamentMatch(tournament, mid: nextMid, match: nextMatch)
    }
    
    // Returns a match from the tournament object. If not found, returns an empty dictionary.
    func getTournamentMatch(tournament: PFObject, mid: Int) -> [String:AnyObject] {
        if let match = tournament["matches"].objectForKey(String(mid)) as? [String:AnyObject] {
            return match
        }
        
        return [String:AnyObject]()
    }
    
    // Replace a match element in the tournament object
    func updateTournamentMatch(tournament: PFObject, mid: Int, match: [String:AnyObject]) {
        var matches = tournament["matches"] as [String:[String:AnyObject]]
        matches.updateValue(match, forKey: String(mid))
        tournament.setObject(matches, forKey: "matches")
    }
    
    // Returns a participants name as a string given their seed index.
    func getParticipantNameFromIndex(tournament: PFObject, index: Int) -> String {
        if tournament["participants"].count > index {
            let participant = tournament["participants"].objectAtIndex(index) as NSDictionary
            return participant["name"] as NSString
        }
        
        return ""
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// Adds Tourney brand color helper functions.
extension UIColor {
    class func appBlueColor() -> UIColor {
        return UIColor(red: 52.0/255.0, green: 163.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    }
    
    class func appBackgroundColor() -> UIColor {
        return UIColor(red: 39.0/255.0, green: 39.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    }
    
    class func appLightBackgroundColor() -> UIColor {
        return UIColor(red: 61.0/255.0, green: 66.0/255.0, blue: 77.0/255.0, alpha: 1.0)
    }
    
    class func appSelectedColor() -> UIColor {
        return UIColor(red: 77.0/255.0, green: 83.0/255.0, blue: 96.0/255.0, alpha: 1.0)
    }
    
    class func appSeparatorColor() -> UIColor {
        return UIColor(red: 87.0/255.0, green: 87.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    }
    
    class func appLightColor() -> UIColor {
        return UIColor(red: 142.0/255.0, green: 144.0/255.0, blue: 151.0/255.0, alpha: 1.0)
    }
    
    class func appGreenColor() -> UIColor {
        return UIColor(red: 52.0/255.0, green: 219.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    }
    
    class func appRedColor() -> UIColor {
        return UIColor(red: 219.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
}

