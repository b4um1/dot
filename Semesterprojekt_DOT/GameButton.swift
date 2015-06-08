//
//  GameButton.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 07.06.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import Foundation
import UIKit

class GameButton: UIButton {
    
    var image_standard = UIImage(named:"dot_standard")
    var image_move = UIImage(named:"dot_move")
    var image_locked = UIImage(named:"dot_locked")
    
    var isLocked = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage(image_standard, forState: .Normal)
    }
    
    func setImageMove(){
        self.setImage(image_move, forState: .Normal)
    }
    func setImageStandard(){
        self.setImage(image_standard, forState: .Normal)
    }
    func setImageLocked(){
        self.setImage(image_locked, forState: .Normal)
        isLocked = true
    }
}
