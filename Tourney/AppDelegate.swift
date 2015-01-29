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
        Parse.enableLocalDatastore()
        Parse.setApplicationId("4zjfhYhbjTMD58b8IXsxjrEsR0xzyUsIIkJkzZ5r", clientKey: "1ZSLFOheFZwo2AjsbGngDGfBClkUOLfJvS6Nxx1b")
        
        self.initialViewController = self.window?.rootViewController
        
        return true
    }
    
    func getKnockoutMap(tournament: PFObject) -> [[String:Int]] {
        let participantCount = tournament["participants"].count as Int
        let logParticipantCount = log(Double(participantCount))
        let logMultiple = log(Double(2))
        let size = pow(2, ceil(logParticipantCount/logMultiple));
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
    
    // Returns a match from the tournament object. If not found, returns an empty dictionary.
    func getTournamentMatch(tournament: PFObject, mid: Int) -> [String:AnyObject] {
        if let match = tournament["matches"].objectForKey(String(mid)) as? [String:AnyObject] {
            return match
        }
        
        return [String:AnyObject]()
    }
    
    // Replace a match element in the tournament object
    func updateTournamentMatch(tournament: PFObject, mid: Int, match: [String:AnyObject]) {
        tournament["matches"].setValue(match, forKey: String(mid))
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

