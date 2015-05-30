//
//  PageItemController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit

class PageItemController: UIViewController {

    var itemIndex: Int = 0
    var labelName: String = ""
    
    @IBOutlet weak var myLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel?.text = labelName
    }
}
