//
//  GameScreenController.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 30.05.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import Foundation
import UIKit

class GameScreenController : UIViewController {
    
    @IBOutlet weak var label_opponent: UILabel!
    @IBOutlet weak var label_steps: UILabel!
    @IBOutlet weak var label_bgl: UILabel!
    
    @IBOutlet var gameDots: [UIButton]!
    
    var oppenentname = ""   // name of the opponent
    var playernr = 1        // you are player 1 for standard
    var stepcounter = 0     // counts the steps made by gamer 1
    
    override func viewDidLoad() {
        setUpView()
        println("\(gameDots.count)")
    }
    
    func setUpView(){
        label_opponent.text = "Opponent: \(oppenentname)"
        label_steps.text = "Steps: \(stepcounter)"
        
        setUpBackgroundLabel(label_bgl)
    }
    
    
    @IBAction func gameButtonTouched(sender: AnyObject){
        println("touched buuton")
    }
    
    func setUpBackgroundLabel(fromLabel: UILabel){
        fromLabel.layer.cornerRadius = 8
        fromLabel.layer.masksToBounds = true
    }
}
