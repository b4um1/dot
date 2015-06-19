//
//  PageItemController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import PNChartSwift

class PageItemController: UIViewController {

    var itemIndex: Int = 0
    var name: String = ""
    var date: NSDate?
    var totalGames: Int = 0
    var wins: Int = 0
    
    var barChart = PNBarChart()
    
    @IBOutlet weak var avatar: UIImageView!
    var labelName: UILabel!
    var labelDate: UILabel!
    var labelTotalGames: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var height: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        height = view.frame.size.height
        
        //labelName?.text = name
        //labelTotalGames?.text = totalGames.description + " games!"
        //labelDate?.text = "last game at: " + dateformatterDate(date!).description
    }
    
    override func viewWillAppear(animated: Bool) {
        /*
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        */
        drawView()

    }
    
    func drawView() {
        setChartData()
        
        labelName = UILabel(frame: CGRectMake(0, 0, 200, 30))
        //labelName.center = CGPointMake(view.frame.width / 1.5, height! / 2 - 100)
        labelName.center = CGPointMake(view.frame.width / 2, 50)
        labelName.textAlignment = NSTextAlignment.Center
        labelName.textColor = UIColor.blackColor()
        labelName.font = DotFontStyle(40.0)
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
            labelDate.text = "last game: " + dateformatterDate(date!).description
        }
        
        self.view.addSubview(labelName)
        self.view.addSubview(labelTotalGames)
        self.view.addSubview(labelDate)
        self.view.addSubview(barChart)
    }
    
    func dateformatterDate(date: NSDate) -> NSString
    {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
    func setChartData() {
        var barChart = PNBarChart(frame: CGRectMake(0, 200, self.view.frame.size.width / 3, height! / 2.2))
        
        var labelWins = UILabel(frame: CGRectMake(0, 0, 200, 21))
        labelWins.center = CGPointMake(barChart.frame.width / 2, barChart.frame.height + 30 + 150)
        labelWins.textAlignment = NSTextAlignment.Center
        labelWins.textColor = DotGreenColor
        labelWins.font = DotFontStyle(20.0)
        labelWins.text = wins.description + " wins"
        
        var labelDefeats = UILabel(frame: CGRectMake(0, 0, 200, 21))
        labelDefeats.center = CGPointMake(barChart.frame.width / 2, 30  + 150)
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
