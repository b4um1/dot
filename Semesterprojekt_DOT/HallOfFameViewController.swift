//
//  HallOfFameViewController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import CoreData


/// Represents the Hall of Fame View. It contains several Pages of players, with detailed gamestatistics, with which you have played in the past
public class HallOfFameViewController: UIViewController, UIPageViewControllerDataSource, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var players = [Player]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Hall of Fame"
        
        /*
        var myDate = NSDate()
        storeDummyData("Thomas' iPhone 5", wins: 6, amount: 8, date: myDate, avatarId: 40)
        storeDummyData("Mario's iPhone 5s", wins: 11, amount: 20, date: myDate, avatarId: 14)
        storeDummyData("Maximilians iPhone 6 Plus", wins: 0, amount: 3, date: myDate, avatarId: 38)
        */

        loadFromCoreData()
        //println(players)
        
        if players.count == 0 {
            showAlert()
            
        }
        
        createPageViewController()
        setupPageControl()
        
    }
    
    /**
    Alert, which informs, when the hall of fame is empty
    */
    func showAlert() {
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: "Oups 😵", message: "You haven't played any games yet! 😉", preferredStyle: .Alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            //self.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        var attributes = [
            NSFontAttributeName: DotFontStyle(30)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        setupPageControl()
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /**
    This functions loads the user data from core data
    */
    func loadFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Player")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [Player]?
        if let results = fetchedResults {
            players = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    /**
    Creates several pages from the different amount of players. You can swipe through with swipe to the left or right
    */
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if players.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    /**
    Sets up the UI of the Pagecontroller
    */
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex+1 < players.count {
            return getItemController(itemController.itemIndex + 1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        
        if itemIndex < players.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.name = players[itemIndex].name
            pageItemController.date = players[itemIndex].lastGame
            pageItemController.totalGames = players[itemIndex].amount as Int
            pageItemController.wins = players[itemIndex].wins as Int
            pageItemController.avatarId = players[itemIndex].avatar as Int
            
            return pageItemController
        }
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return players.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
