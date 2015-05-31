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
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTotalGames: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelName?.text = name
        labelTotalGames?.text = totalGames.description
    }
    
    override func viewWillAppear(animated: Bool) {
        
        drawView()
    }
    
    func drawView() {
        setChartData()
        self.view.addSubview(barChart)
    }
    
    func setChartData() {
        var barChart = PNBarChart(frame: CGRectMake(0, 50, self.view.frame.size.width / 3, self.view.frame.size.height / 1.3))
        
        barChart.barBackgroundColor = UIColor.redColor()
        
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

        barChart.backgroundColor = UIColor.blackColor()
        view.addSubview(barChart)
        
    }

}
