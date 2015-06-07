//
//  GameScreenViewController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 05/06/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit

class GameScreenViewController: UIViewController {

    @IBOutlet weak var mOpponent: UILabel!
    @IBOutlet weak var mSteps: UILabel!
    @IBOutlet weak var mTurn: UILabel!
    @IBOutlet weak var startingPoint: GameButton!
    
    
    @IBOutlet var mGameButtons: [UIButton]!
    
    
    var oppenentname = ""   // name of the opponent
    var playernr = 0      // you are player 1 for standard
    var stepcounter = 0     // counts the steps made by gamer 1
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        
        mOpponent.text = "Player \(playernr): \(oppenentname)"
        mSteps.text = "Steps: \(stepcounter)"
        
        if playernr == 1{
            mTurn.text = "It's your turn";
        }
        
        self.startingPoint.setImageMove()
        
    }
    
    func setUpBackgroundLabel(fromLabel: UILabel){
        fromLabel.layer.cornerRadius = 8
        fromLabel.layer.masksToBounds = true
    }

    
    @IBAction func onButtonPressed(sender: AnyObject) {
        var button = sender as! GameButton
        
        // Die Animation haut jetzt noch nicht so wirklich hin, da mach ich aber Morgen, Montag 8. Juni weiter, also keine sorgen
        
        UIView.animateWithDuration(1.0, animations:{
            button.frame = CGRectMake(self.startingPoint.frame.origin.x, self.startingPoint.frame.origin.y, self.startingPoint.frame.size.width, self.startingPoint.frame.size.height)
        })
        
        if playernr == 1 {
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
