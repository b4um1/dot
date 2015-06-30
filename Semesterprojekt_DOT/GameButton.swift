//
//  GameButton.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 07.06.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import Foundation
import UIKit

/// Is the instance of one single Game Button
 class GameButton: UIButton {
    
    var image_standard = UIImage(named:"dot_standard")
    var image_move = UIImage(named:"dot_move")
    var image_locked = UIImage(named:"dot_locked")
    var image_action = UIImage(named:"dot_action")
    
    var isLocked = false
    var isMove = false
    var isAction = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage(image_standard, forState: .Normal)
    }
    
    func setImageMove(){
        self.setImage(image_move, forState: .Normal)
        //self.alpha = 1.0
        isMove = true
        isAction = false
    }
    func setImageStandard(){
        self.setImage(image_standard, forState: .Normal)
        //self.alpha = 1.0
        isLocked = false
        isAction = false
    }
    func setImageLocked(){
        self.setImage(image_locked, forState: .Normal)
        //self.alpha = 1.0
        isLocked = true
    }
    func setImageAction() {
        self.setImage(image_action, forState: .Normal)
        //self.alpha = 0.5
        isAction = true
    }
}
