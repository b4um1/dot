//
//  Overlay.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 09.06.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import Foundation


public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!) {
        overlayView = UIView(frame: UIScreen.mainScreen().bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        
        var label = UILabel(frame: CGRectMake(0, 0, 250, 21))
        label.center = overlayView.center
        label.center.y+=30
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = "Wait, it's your opponents turn!"
        
        overlayView.addSubview(label)
        
        var layoutconstraint = NSLayoutConstraint (item: label,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: activityIndicator,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 10)
        
        //overlayView.addConstraint(layoutconstraint)
        
        
        
        activityIndicator.startAnimating()
        view.addSubview(overlayView)
        println("view should be visible")
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
