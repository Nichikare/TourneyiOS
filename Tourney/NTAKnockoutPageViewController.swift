//
//  NTAKnockoutPageViewController.swift
//  Tourney
//
//  Created by Joe Fender on 21/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAKnockoutPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var tournament = PFObject(className: "Tournament")
    var map = [[String:Int]]()
    var roundCount: Int = 0

    @IBOutlet weak var navigationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.map = self.appDelegate.getKnockoutMap(self.tournament)
        let size = self.appDelegate.getKnockoutMapSize(self.tournament)
        self.roundCount = Int(log2(size))
        
        let tableViewController = self.viewControllerAtIndex(0)
        let viewControllers: NSArray = [tableViewController]
        self.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.view.backgroundColor = UIColor.appBackgroundColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let title = self.tournament["title"] as! String
        self.navigationButton.setTitle(title, forState: .Normal)
        self.navigationButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.navigationButton.sizeToFit()
    }
    
    func viewControllerAtIndex(var index: Int) -> UIViewController! {
        if self.roundCount == 0 || index >= self.roundCount {
            return nil
        }
        
        let tableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("KnockoutTableViewController") as! NTAKnockoutTableViewController
        
        tableViewController.pageViewController = self
        tableViewController.tournament = self.tournament
        tableViewController.pageIndex = index
        
        index = index + 1
        tableViewController.matches = self.map.filter({$0["round"] == index})
        
        return tableViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let tableViewController = viewController as! NTAKnockoutTableViewController
        var index = tableViewController.pageIndex
        if index == 0 {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let tableViewController = viewController as! NTAKnockoutTableViewController
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editSegue") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var tableViewController = navigationController.topViewController as! NTAEditTournamentTableViewController
            tableViewController.tournament = self.tournament
        }
    }
}
