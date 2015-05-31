//
//  HallOfFameViewController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import CoreData

class HallOfFameViewController: UIViewController, UIPageViewControllerDataSource {
    
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
        storeDummyData("Thomas", wins: 6, amount: 8, date: myDate)
        storeDummyData("Mario", wins: 11, amount: 20, date: myDate)
        */

        loadFromCoreData()
        //println(players)
        
        createPageViewController()
        setupPageControl()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false
        var attributes = [
            NSFontAttributeName: DotFontStyle(30)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        setupPageControl()
    }
    
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
    
    func storeDummyData(name: String, wins: Int, amount: Int, date: NSDate) {
        var player1: Player?
        
        var entity = NSEntityDescription.entityForName("Player", inManagedObjectContext:appDelegate.managedObjectContext!)
        player1 = Player(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext!)
        
        player1!.name = name
        player1!.amount = amount
        player1!.lastGame = date
        player1!.wins = wins
        
        appDelegate.managedObjectContext?.save(nil)
    }
    
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
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.blackColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.lightGrayColor()
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
