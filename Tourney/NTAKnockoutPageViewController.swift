//
//  NTAKnockoutPageViewController.swift
//  Tourney
//
//  Created by Joe Fender on 21/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAKnockoutPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var tournament = PFObject(className: "Tournament")
    var map = [[String:Int]]()
    var roundCount = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.map = self.appDelegate.getKnockoutMap(self.tournament)
        // TODO get the number of rounds automatically
        // self.roundCount = self.appDelegate.getRoundCount(self.tournament)
        
        let tableViewController = self.viewControllerAtIndex(0)
        let viewControllers: NSArray = [tableViewController]
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.tournament["title"] as NSString
    }
    
    func viewControllerAtIndex(var index: Int) -> UIViewController! {
        if self.roundCount == 0 || index >= self.roundCount {
            return nil
        }
        
        let tableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("KnockoutTableViewController") as NTAKnockoutTableViewController
        
        tableViewController.tournament = self.tournament
        tableViewController.pageIndex = index
        
        index = index + 1
        tableViewController.matches = self.map.filter({$0["round"] == index})
        
        return tableViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let tableViewController = viewController as NTAKnockoutTableViewController
        var index = tableViewController.pageIndex
        if index == 0 {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let tableViewController = viewController as NTAKnockoutTableViewController
        let index = tableViewController.pageIndex + 1
        if index == self.roundCount {
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.roundCount
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
