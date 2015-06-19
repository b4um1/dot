//
//  Player.swift
//  
//
//  Created by User on 19/06/15.
//
//

import Foundation
import CoreData

@objc(Player)
class Player: NSManagedObject {

    @NSManaged var amount: NSNumber
    @NSManaged var lastGame: NSDate
    @NSManaged var name: String
    @NSManaged var wins: NSNumber
    @NSManaged var avatar: NSNumber

}
