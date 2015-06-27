//
//  GameScreenViewController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 05/06/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class GameScreenViewController: UIViewController {

    @IBOutlet weak var mOpponent: UILabel!
    @IBOutlet weak var mSteps: UILabel!
    @IBOutlet weak var mTurn: UILabel!
    @IBOutlet weak var startingPoint: GameButton!
    @IBOutlet weak var movingPoint: GameButton!
    @IBOutlet var mGameButtons: [UIButton]!
    
    var lockedDotsTags = [Int]()
    let numberOfDefaultLockedDots = 10
    var appDelegate: AppDelegate! //appdelegate for communication with the mpc handler
    var oppenentname = ""   // name of the opponent
    var playernr = 0      // you are player 1 for standard
    var stepcounter = 0     // counts the steps made by gamer 1
    var firstMoveDot = true
    
    var posofmoving = 0
    var winnerAnimationIndex = 0    // should the dot move up, down, left, right?
    
    var players = [Player]()
    var playerId: Int = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    let avatarKey = "avatarId"
    var opponentsAvatar = 0
    var myavatar = 0
    
    let JSON_LOCKEDDOTS = "lockeddots"
    let JSON_MOVINGDOT = "movingdot"
    let JSON_NEWLOCKEDDOT = "newlockeddot"
    let JSON_WINNINGANIMATION = "winnerAnimationIndex"
    let JSON_AVATARID = "avatar_id"
    let JSON_CANCELGAME = "cancelGame"
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        initGameScreen()
    }
    
    override func viewDidAppear(animated: Bool) {
        animateDots()
    }
    
    override func viewDidLayoutSubviews() {
        if playernr == 1 {
            setUpMovingDot()
        }
    }
    
    func animateDots(){
        for b in mGameButtons {
            b.hidden = false
        }
        // animation of locked dots
        for button in mGameButtons {
            var b = button as! GameButton
            if b.isLocked {
                var buttonFrame = b.frame
                b.frame.origin.y = -view.frame.height / 2
                
                UIView.animateWithDuration(1.0, animations:{
                    b.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y, b.frame.size.width, b.frame.size.height)
                })
                
                b.transform = CGAffineTransformMakeScale(2, 2)
                UIView.beginAnimations("fadeInAndGrow", context: nil)
                UIView.setAnimationDuration(1)
                b.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                UIView.commitAnimations()
            }
        }

    }
    
    func loadFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Player")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [Player]?
        
        if let results = fetchedResults {
            players = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func initGameScreen() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        mOpponent.text = "Opponet: \(oppenentname)"
        mSteps.text = "Steps: \(stepcounter)"
        myavatar = defaults.integerForKey(avatarKey)
        
        for b in mGameButtons { // hide all buttons because of the animation
            b.hidden = true
        }
        
        if playernr == 1{
            mTurn.text = "Player 1 - It's your turn";
            posofmoving = 27
            generateLockedDots()
            sendGameSetup()
        } else {
            mTurn.text = "Player 2 - Wait until your opponent has done his turn"
            LoadingOverlay.shared.showOverlay(self.view)
        }
    }
    
    func clearGameSettings() {
        playernr = 0
        posofmoving = 0
        winnerAnimationIndex = 0
        /*
        lockedDotsTags = [Int]()
        oppenentname = ""   // name of the opponent
        stepcounter = 0     // counts the steps made by gamer 1
        
        posofmoving = 0
        winnerAnimationIndex = 0    // should the dot move up, down, left, right?
        firstConnection = true
        firstMoveDot = true
        
        initGameScreen()
        */
    }

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if playernr == 1 { // if player 1 is on a border dot and clicks in the view (he wins)
            var isWinner = false
            var x: CGFloat = 0
            var y: CGFloat = 0
            if posofmoving < 8 && posofmoving >= 0 {
                isWinner = true // move up
                x = movingPoint.frame.origin.x
                y = movingPoint.frame.origin.y - 35
                winnerAnimationIndex = 1
            }
            if posofmoving < 64 && posofmoving > 56 {
                isWinner = true // move down
                x = movingPoint.frame.origin.x
                y = movingPoint.frame.origin.y + 35
                winnerAnimationIndex = 2
            }
            if posofmoving == 8 || posofmoving == 16 || posofmoving == 24 || posofmoving == 32 || posofmoving == 40 || posofmoving == 48 {
                isWinner = true // move left
                x = movingPoint.frame.origin.x - 35
                y = movingPoint.frame.origin.y
                winnerAnimationIndex = 3
            }
            if posofmoving == 15 || posofmoving == 23 || posofmoving == 31 || posofmoving == 39 || posofmoving == 47 || posofmoving == 55 {
                isWinner = true // move right
                x = movingPoint.frame.origin.x + 35
                y = movingPoint.frame.origin.y
                winnerAnimationIndex = 4
            }
            
            if isWinner {
                sendMovingButton()
                UIView.animateWithDuration(1.0, animations:{
                    self.movingPoint.frame = CGRectMake(x, y, self.movingPoint.frame.size.width, self.movingPoint.frame.size.height)
                })
                UIView.commitAnimations()
                gameOverWithWinner(winnerPlayer1: true)
                showEndAlert(true)
            }
        }
    }
    
    func showEndAlert(winning: Bool) {
        var title = ""
        if winning {
            title = "Congratulations! You win!"
        } else {
            title = "You lost!"
        }
        
        var message = "Do you want to play again?"
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
            //self.cancelGame()
        }
        
        let noAction = UIAlertAction(title: "No", style: .Default) { action in
            //self.cancelGame()
        }
        
        // Add the actions.
        alertCotroller.addAction(yesAction)
        //alertCotroller.addAction(noAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func cancelGame(){
        //sendCancelGame()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setUpMovingDot(){
        //set up the button where player 1 starts -- should happen randomly
        
        if winnerAnimationIndex > 0 { // there is a winner
            var x: CGFloat = 0
            var y: CGFloat = 0
            if winnerAnimationIndex == 1 {
                x = movingPoint.frame.origin.x
                y = movingPoint.frame.origin.y - 35
            } else if winnerAnimationIndex == 2 {
                x = movingPoint.frame.origin.x
                y = movingPoint.frame.origin.y + 35
            } else if winnerAnimationIndex == 3 {
                x = movingPoint.frame.origin.x - 35
                y = movingPoint.frame.origin.y
            } else if winnerAnimationIndex == 4 {
                x = movingPoint.frame.origin.x + 35
                y = movingPoint.frame.origin.y
            }
            gameOverWithWinner(winnerPlayer1: true)
            showEndAlert(false)
            UIView.animateWithDuration(1.0, animations:{
                self.movingPoint.frame = CGRectMake(x, y, self.movingPoint.frame.size.width, self.movingPoint.frame.size.height)
            })
            UIView.commitAnimations()
            
        } else {
            (mGameButtons[posofmoving] as! GameButton).isMove = true
            var button = mGameButtons[posofmoving]
            var offset: CGFloat = 18.0
            if button.superview!.tag == 0 {
                offset = 0.0
            }
            var x = button.frame.origin.x - offset
            var y = button.superview!.frame.origin.y - movingPoint.superview!.frame.origin.y
            UIView.animateWithDuration(1.0, animations:{
                self.movingPoint.frame = CGRectMake(x, y, button.frame.size.width, button.frame.size.height)
            })
            self.movingPoint.setImageMove()
        }
    }
    
    func sendGameSetup(){ //movingdot and locked dots and avatarID
        var json: JSON = [JSON_MOVINGDOT:posofmoving,JSON_WINNINGANIMATION:winnerAnimationIndex,JSON_LOCKEDDOTS:lockedDotsTags,JSON_AVATARID:myavatar] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        var stringjson = json.description
        
        //sendjson
        println("sendjson: \(stringjson)")
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
        
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        oppenentname = senderPeerId.displayName
        
        let json = JSON(data: receivedData)
        //println("ReceivedJson: \(json.description)")
        
        winnerAnimationIndex = json[JSON_WINNINGANIMATION].intValue
        
        var avatarId = json[JSON_AVATARID].intValue
        if avatarId != 0 {
            opponentsAvatar = avatarId
        }
        
        if playernr == 1 { //handle new locked dot
            var button: GameButton
            var newpos = json[JSON_NEWLOCKEDDOT].intValue

            LoadingOverlay.shared.hideOverlayView()
            
            button = mGameButtons[newpos] as! GameButton
            button.setImageLocked()
            newLockedDotAnimation(button)
        }
        
        if playernr == 2 { //handle pos of moving dot
            posofmoving = json[JSON_MOVINGDOT].intValue
            
            if let arrayLockedDots = json[JSON_LOCKEDDOTS].array {
                println("jsonlockeddots: \(arrayLockedDots.count)")
                
                for index in 0...arrayLockedDots.count-1 {
                    var button: GameButton
                    button = mGameButtons[arrayLockedDots[index].intValue] as! GameButton
                    button.setImageLocked()
                }
            }
            setUpMovingDot()
            
            if firstMoveDot{
                firstMoveDot = false
            }else{
                LoadingOverlay.shared.hideOverlayView()
            }
        }
    }
    
    func sendMovingButton(){
        var json: JSON = [JSON_MOVINGDOT:posofmoving, JSON_WINNINGANIMATION:winnerAnimationIndex] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    //not used, irregular
//    func sendAvatar(avatarId: Int) {
//        
//        var json: JSON = [JSON_AVATARID:avatarId]
//        var jsonrawdata = json.rawData(options: nil, error: nil)
//        
//        var error:NSError?
//        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
//        
//        if error != nil{
//            println("Couldn't send message: \(error?.localizedDescription)")
//        }
//        
//    }

    
    func sendNewLockedDot(posoflocked: Int){
        var json: JSON = [JSON_NEWLOCKEDDOT:posoflocked,JSON_AVATARID:myavatar] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    func sendCancelGame(){
        let messageDict = [JSON_CANCELGAME:"cancel"]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
    }
    
    /*
    func sendNewGameRequest(playAgain: Bool){
        let messageDict = ["newGame":"\(playAgain)"]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    */
    
    func generateLockedDots(){
        for i in 0...numberOfDefaultLockedDots - 1 {
            var button: GameButton
            var randomNumber:UInt32 = 0
            do {
                randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                button = mGameButtons[Int(randomNumber)] as! GameButton
            } while button.isLocked || button.isMove
            button.setImageLocked()
            lockedDotsTags.append(Int(randomNumber))
        }

    }

    @IBAction func onButtonPressed(sender: AnyObject) {
        var button = sender as! GameButton
        println("#:\(button.tag) origin: \(button.frame.origin)")
        
        if playernr == 1 {
            var offset: CGFloat = 18.0
            if button.superview!.tag == 0 {
                offset = 0.0
            }
            var x = button.frame.origin.x - offset
            var y = button.superview!.frame.origin.y - movingPoint.superview!.frame.origin.y
            
            
            if isValidPosition(x, y: y, button: button) {
                UIView.animateWithDuration(1.0, animations:{
                    self.movingPoint.frame = CGRectMake(x, y, button.frame.size.width, button.frame.size.height)
                })
                stepcounter++
                mSteps.text = "Steps: \(stepcounter)"
                posofmoving = button.tag - 1
                sendMovingButton()
                LoadingOverlay.shared.showOverlay(self.view)
            }
        }else{
            if !button.isLocked && button.tag - 1 != posofmoving{
                stepcounter++
                mSteps.text = "Steps: \(stepcounter)"
                button.setImageLocked()
                newLockedDotAnimation(button)
                sendNewLockedDot(button.tag-1)
                if isDotCaged() {
                    gameOverWithWinner(winnerPlayer1: false)
                    showEndAlert(true)
                }
                LoadingOverlay.shared.showOverlay(self.view)
            }
        }
    }
    
    func isDotCaged() -> Bool {
        var counter = 0
        for button in mGameButtons {
            var offset: CGFloat = 18.0
            if button.superview!.tag == 0 {
                offset = 0.0
            }
            var x = button.frame.origin.x - offset
            var y = button.superview!.frame.origin.y - movingPoint.superview!.frame.origin.y

            let dotSize = movingPoint.frame.width + 2
            if ((x - movingPoint.frame.origin.x) < dotSize) && ((x - movingPoint.frame.origin.x) > -dotSize) && ((y - movingPoint.frame.origin.y) < dotSize) && ((y - movingPoint.frame.origin.y) > -dotSize) && (button as! GameButton).isLocked {
                counter++
            }
        }
        if counter == 6 {
            return true
        } else {
            return false
        }
    }
    
    func newLockedDotAnimation(button: GameButton) {
        button.transform = CGAffineTransformMakeScale(10, 10)
        UIView.beginAnimations("scale", context: nil)
        UIView.setAnimationDuration(0.8)
        button.transform = CGAffineTransformMakeScale(1.0, 1.0)
        UIView.commitAnimations()
    }
    
    func isValidPosition(x: CGFloat, y: CGFloat, button: GameButton) -> Bool {
        var isValid = false
        
        // +2 -> space between two dots
        let dotSize = movingPoint.frame.width + 2
        if ((x - movingPoint.frame.origin.x) < dotSize) && ((x - movingPoint.frame.origin.x) > -dotSize) && ((y - movingPoint.frame.origin.y) < dotSize) && ((y - movingPoint.frame.origin.y) > -dotSize) {
            isValid = true
        }
        
        for b in mGameButtons {
            if b == button {
                if (b as! GameButton).isLocked || b.tag - 1 == posofmoving {
                    isValid = false
                }
            }
        }
        return isValid
    }
    
    func gameOverWithWinner(#winnerPlayer1: Bool) {
        loadFromCoreData()
        var alreadyInCoreData = false
        for (index, player) in enumerate(players) {
            if oppenentname == player.name {
                playerId = index
                alreadyInCoreData = true
            }
        }
        if !alreadyInCoreData {
            var entity = NSEntityDescription.entityForName("Player", inManagedObjectContext:appDelegate.managedObjectContext!)
            var player = Player(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext!)
            player.name = oppenentname
            player.wins = 0
            player.amount = 0
            player.avatar = opponentsAvatar
            
            appDelegate.managedObjectContext?.save(nil)
            loadFromCoreData()
        }
        
        if winnerPlayer1 {
            if playernr == 1 {
                players[playerId].amount = Int(players[playerId].amount) + 1
                players[playerId].wins = Int(players[playerId].wins) + 1
            } else {
                players[playerId].amount = Int(players[playerId].amount) + 1
            }
        } else {
            if playernr == 1 {
                players[playerId].amount = Int(players[playerId].amount) + 1
            } else {
                players[playerId].amount = Int(players[playerId].amount) + 1
                players[playerId].wins = Int(players[playerId].wins) + 1
            }
        }
        saveToCoreData()
    }
    
    func saveToCoreData() {
        let predicate = NSPredicate(format: "name == %@", oppenentname)
        
        let fetchRequest = NSFetchRequest(entityName: "Player")
        fetchRequest.predicate = predicate
        
        let fetchedEntities = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Player]
        
        fetchedEntities.first?.wins = players[playerId].wins
        fetchedEntities.first?.amount = players[playerId].amount
        
        appDelegate.managedObjectContext!.save(nil)
    }
}
