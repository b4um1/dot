//
//  Overlay.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 09.06.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import Foundation

/// Represents a View, with whom you can lock the current screen until you unlock it
public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var overlayShown = false
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    /**
    Returns whether the overlay is shown at the moment
    
    :returns: bool, true or false
    */
    public func isOverlayShown() -> Bool {
        return overlayShown
    }
    
    /**
    Adds the overlay to the current view
    
    :param: view UIView
    */
    public func showOverlay(view: UIView!) {
        overlayShown = true
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
    }
    
    /**
    Hides the overlay, if it is shown
    */
    public func hideOverlayView() {
        overlayShown = false
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
