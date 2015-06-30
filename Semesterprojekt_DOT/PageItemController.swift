//
//  PageItemController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import PNChartSwift

/// Represents a Gamerpage in the Hall of Fame. There you can see how often you played, how often you won/lost against somebody else
public class PageItemController: UIViewController {

    var itemIndex: Int = 0
    var name: String = ""
    var date: NSDate?
    var totalGames: Int = 0
    var wins: Int = 0
    
    var barChart = PNBarChart()
    
    var avatarId: Int = 1 {
        didSet {
            if let imageView = avatar {
                imageView.image = UIImage(named: "avatar\(avatarId)")
            }
        }
    }
    
    @IBOutlet weak var avatar: UIImageView!
    
    var labelName: UILabel!
    var labelDate: UILabel!
    var labelTotalGames: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var height: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.image = UIImage(named: "avatar\(avatarId)")
        
        height = view.frame.size.height
        
        //labelName?.text = name
        //labelTotalGames?.text = totalGames.description + " games!"
        //labelDate?.text = "last game at: " + dateformatterDate(date!).description
    }
    
    override func viewWillAppear(animated: Bool) {
        drawView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        wiggle()
    }
    
    
    /**
    This functions animates the avatar icon of the gamer. It "wiggles".
    */
    func wiggle() {
        let duration = 0.3
        let options = UIViewKeyframeAnimationOptions.Autoreverse | UIViewKeyframeAnimationOptions.Repeat
        let rotationValue = 0.07
        let rotation = CGFloat(rotationValue)
        
        self.avatar.transform = CGAffineTransformMakeRotation(-CGFloat(rotationValue/2))
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.avatar.transform = CGAffineTransformMakeRotation(rotation)
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.avatar.transform = CGAffineTransformMakeRotation(-rotation)
            })
        }, completion: nil)
        
    }

    /**
    Set up the UI of the Page
    */
    func drawView() {
        setChartData()
        
        labelName = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 10, 30))
        //labelName.center = CGPointMake(view.frame.width / 1.5, height! / 2 - 100)
        labelName.center = CGPointMake(view.frame.width / 2, 50)
        labelName.textAlignment = NSTextAlignment.Center
        labelName.textColor = UIColor.blackColor()
        labelName.font = DotFontStyle(28.0)
        labelName.text = name
        
        labelTotalGames = UILabel(frame: CGRectMake(0, 0, 200, 25))
        labelTotalGames.center = CGPointMake(view.frame.width / 1.5, height! / 2)
        labelTotalGames.textAlignment = NSTextAlignment.Left
        labelTotalGames.textColor = UIColor.whiteColor()
        labelTotalGames.font = DotFontStyle(20.0)
        labelTotalGames.text = totalGames.description + " games!"
        
        labelDate = UILabel(frame: CGRectMake(0, 0, 200, 25))
        labelDate.center = CGPointMake(view.frame.width / 1.5, height! / 2 + 50)
        labelDate.textAlignment = NSTextAlignment.Left
        labelDate.font = DotFontStyle(20.0)
        labelDate.textColor = UIColor.whiteColor()
        if date != nil {
            println("DATE ISNT NIL")
            labelDate.text = "last game: " + dateformatterDate(date!).description
        }
        
        self.view.addSubview(labelName)
        self.view.addSubview(labelTotalGames)
        self.view.addSubview(labelDate)
        self.view.addSubview(barChart)
    }
    
    /**
    Formats a date to dd.MM.yyyy and returns it as NSString
    
    :param: date NSDate
    
    :returns: Formated NSString
    */
    func dateformatterDate(date: NSDate) -> NSString
    {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
    /**
    Set up chart data. Set wins/loses.
    */
    func setChartData() {
        var barChart = PNBarChart(frame: CGRectMake(0, 200, self.view.frame.size.width / 3, height! / 2.2))
        
        var labelWins = UILabel(frame: CGRectMake(0, 0, 200, 21))
        labelWins.center = CGPointMake(barChart.frame.width / 2, barChart.frame.height + 30 + 150)
        labelWins.textAlignment = NSTextAlignment.Center
        labelWins.textColor = DotGreenColor
        labelWins.font = DotFontStyle(20.0)
        labelWins.text = wins.description + " wins"
        
        var labelDefeats = UILabel(frame: CGRectMake(0, 0, 200, 21))
        labelDefeats.center = CGPointMake(barChart.frame.width / 2, 50 + 150)
        labelDefeats.textAlignment = NSTextAlignment.Center
        labelDefeats.textColor = DotRedColor
        labelDefeats.font = DotFontStyle(20.0)
        labelDefeats.text = (totalGames - wins).description + " defeats"
        
        barChart.barBackgroundColor = DotRedColor
        
        barChart.backgroundColor = UIColor.clearColor()
                    barChart.yLabelFormatter = ({(yValue: CGFloat) -> NSString in
                        var yValueParsed:CGFloat = yValue
                        var labelText:NSString = NSString(format:"%1.f",yValueParsed)
                        return labelText;
                    })
        
        
        // remove for default animation (all bars animate at once)
        barChart.animationType = .Waterfall
        
        
        barChart.labelMarginTop = 5.0
        barChart.yMaxValue = CGFloat(totalGames)
        //barChart.xLabels = ["SEP 1"]//,"SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
        barChart.yValues = [wins] //,1,12,18,30,10,21]
        barChart.showLabel = false
        barChart.strokeChart()
        
        //barChart.delegate = self

        barChart.backgroundColor = UIColor.clearColor()
        view.addSubview(barChart)
        view.addSubview(labelWins)
        view.addSubview(labelDefeats)
    }
}
