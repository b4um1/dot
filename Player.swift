//
//  Player.swift
//  Semesterprojekt_DOT
//
//  Created by User on 30/05/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import Foundation
import CoreData

@objc(Player)
class Player: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var amount: NSNumber
    @NSManaged var wins: NSNumber
    @NSManaged var lastGame: NSDate

}
