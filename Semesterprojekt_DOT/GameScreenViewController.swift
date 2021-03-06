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


extension Array {
    func contains<T : Equatable>(obj: T) -> Bool {
        let filtered = self.filter {$0 as? T == obj}
        return filtered.count > 0
    }
}

/// Represents the Game Screen. It manages all the handling between the players. Is responsible of all the multipeerhandling during an active game.
class GameScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mOpponent: UILabel!
    @IBOutlet weak var mSteps: UILabel!
    //@IBOutlet weak var mTurn: UILabel!
    @IBOutlet weak var startingPoint: GameButton!
    @IBOutlet weak var movingPoint: GameButton!
    @IBOutlet var mGameButtons: [UIButton]!
    @IBOutlet weak var playerIndicatorYou: UIImageView!
    @IBOutlet weak var playerIndicatorOpponent: UIImageView!
    @IBOutlet weak var avatar1: UIImageView!
    @IBOutlet weak var avatar2: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    var lockedDotsTags = [Int]()
    var actionDotsTags = [Int]()
    let numberOfDefaultLockedDots = 15
    var numberOfActionFields = 4
    var appDelegate: AppDelegate!   //appdelegate for communication with the mpc handler
    var opponentname = ""           // name of the opponent
    var playernr = 0                // you are player 1 for standard
    var stepcounter = 0             // counts the steps made by gamer 1
    var firstMoveDot = true
    var isExtremeMode = false
    
    var posofmoving = 0
    var winnerAnimationIndex = 0    // should the dot move up, down, left, right?
    
    var players = [Player]()
    var playerId: Int = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    var avatarKey = "avatarId"
    var opponentsAvatar = 0
    var myavatar = 0
    
    var winnerTwo = false
    var giveUp = false
    var iAmTheWinner = false
    
    let JSON_LOCKEDDOTS = "lockeddots"
    let JSON_MOVINGDOT = "movingdot"
    let JSON_NEWLOCKEDDOT = "newlockeddot"
    let JSON_WINNINGANIMATION = "winnerAnimationIndex"
    let JSON_AVATARID = "avatar_id"
    let JSON_CANCELGAME = "cancelGame"
    let JSON_WINNERTWO = "winnerTwo"
    let JSON_GIVEUP = "giveUp"
    let JSON_ACTIONDOTS = "actiondots"
    let JSON_ISACTION = "isAction"
    let JSON_GAMEID = "gameId"
    
    var time = 0
    var timer = NSTimer()
    var TIMEOUT = 10
    
    var gameID: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        println("Anzahl viewcontroller gamescreen: \(self.navigationController?.viewControllers.count)");
        
        if isExtremeMode {
            numberOfActionFields = 6
            TIMEOUT = 3
        }
        initGameScreen()
    }
    override func viewDidDisappear(animated: Bool) {
        //setUpSettings()
    }
    
    /**
    Generates the initiate Gamescreen of Player 1. Set's up the game screen and the avatar of p1. The first move is made by p1. Afterwards the loadingoverlay appears
    */
    func initGameScreen() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        mOpponent.text = "\(opponentname)"
        mSteps.text = "Steps: \(stepcounter)"
        myavatar = defaults.integerForKey(avatarKey)
        avatar1.image = UIImage(named: "avatar\(myavatar)")
        animateMyAvatar()
        
        for b in mGameButtons { // hide all buttons because of the animation
            b.hidden = true
        }
        
        if playernr == 1{
            //mTurn.text = "It's your turn";
            playerIndicatorYou.image = UIImage(named: "dot_move")
            playerIndicatorOpponent.image = UIImage(named: "dot_locked")
            var rand = arc4random_uniform(UInt32(4))
            if rand == 0 {
                posofmoving = 28
            } else if rand == 1 {
                posofmoving = 27
            } else if rand == 2 {
                posofmoving = 35
            } else if rand == 3 {
                posofmoving = 36
            }
            (mGameButtons[posofmoving] as! GameButton).setImageMove()
            generateLockedDots()
            generateActionDots()
            sendGameSetup()
        } else {
            sendGameSetup()
            sendAvatar()
            playerIndicatorOpponent.image = UIImage(named: "dot_move")
            playerIndicatorYou.image = UIImage(named: "dot_locked")
            LoadingOverlay.shared.showOverlay(self.view)
        }
    }
    
    
    /**
    Change the settings to standard
    */
    func setUpSettings(){
        lockedDotsTags = [Int]()
        actionDotsTags = [Int]()
        numberOfActionFields = 4
        opponentname = ""           // name of the opponent
        playernr = 0                // you are player 1 for standard
        stepcounter = 0             // counts the steps made by gamer 1
        firstMoveDot = true
        isExtremeMode = false
        
        posofmoving = 0
        winnerAnimationIndex = 0    // should the dot move up, down, left, right?
        
        players = [Player]()
        playerId = 0
        avatarKey = "avatarId"
        opponentsAvatar = 0
        myavatar = 0
        
        winnerTwo = false
        giveUp = false
    }
    
    /**
    Multipeerconnectivity function, if the state of the connections changes.
    
    :param: notification NSNotification
    */
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        let peerid = userInfo.objectForKey("peerID") as! MCPeerID
        
        //let state = userInfo.objectForKey(test_state) as! Int
        //let peerid = userInfo.objectForKey(test_peerid) as! MCPeerID
        
        //there should be a handling or timer for timeout ...
        
        /*
        if state == MCSessionState.NotConnected.rawValue{
            showEndAlert(winning: false, gaveUp: false, draw: true)
        }
        */
    }

    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        animateDots()
    }
    
    /**
    Function where a player can give up. It is saved as defeat if somebody gives up. The opponent gets notified.
    
    :param: sender UIButton
    */
    @IBAction func giveUpPressed(sender: AnyObject) {
        giveUp = true
        showEndAlert(winning: false, gaveUp: true, draw: false)
        if playernr == 1 {
            gameOverWithWinner(winnerPlayer1: false)
            sendMovingButton()
        } else {
            gameOverWithWinner(winnerPlayer1: true)
            lockedDotsTags.append(-1)
            sendNewLockedDot(lockedDotsTags)
        }
    }
    
    /**
    Start the timer of your turn. Standard are 10 Seconds
    */
    func startTimer() {
        time = TIMEOUT * 100
        progressView.setProgress(1, animated: false)
        progressView.progressTintColor = DotGreenColor
        progressView.trackTintColor = DotRedColor
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("subtractTime"), userInfo: nil, repeats: true)
        
    }
    
    /**
    Subtracts the time and manages the handling when there is a timeout
    */
    func subtractTime() {
        time--
        if(time == 0)  {
            progressView.setProgress(0, animated: true)
            timer.invalidate()
            println("TIMEOUT")
            if playernr == 1 {
                sendMovingButton()
            } else {
                lockedDotsTags.append(100)
                sendNewLockedDot(lockedDotsTags)   // timeout
            }
            stopAnimating()
            LoadingOverlay.shared.showOverlay(self.view)
        } else {
            var state: Float = Float(time) / Float(TIMEOUT * 100)
            progressView.setProgress(state, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if playernr == 1 {
            setUpMovingDot()
        }
    }
    
    /**
    Animates the locked Dots. Scaleeffect
    */
    func animateDots(){
        for b in mGameButtons {
            b.hidden = false
        }
        var isAnimationFinished = false
        // animation of locked dots
        for button in mGameButtons {
            var b = button as! GameButton
            if b.isLocked {
                var buttonFrame = b.frame
                b.frame.origin.y = -view.frame.height / 2
                
                b.transform = CGAffineTransformMakeScale(2, 2)
                UIView.beginAnimations("fadeInAndGrow", context: nil)
                UIView.setAnimationDuration(1)
                b.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                UIView.animateWithDuration(1.0, animations: {
                    b.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y, b.frame.size.width, b.frame.size.height)
                    }, completion: {
                        (finished:Bool) in
                        if !isAnimationFinished {
                            if self.playernr == 1 {
                                self.startTimer()
                            }
                            isAnimationFinished = true
                        }
                    }
                )
                UIView.commitAnimations()
            }
        }
    }
    
    /**
    Loads the players from core data, to check if you have played against this guy or not
    */
    func loadFromCoreData() {
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
    

    /**
    Generate the fields where actions are hidden. The fields are randomly generated between 0 and 64.
    */
    func generateActionDots() {
        for i in 0...numberOfActionFields - 1 {
            var button: GameButton
            var randomNumber:UInt32 = 0
            do {
                randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                button = mGameButtons[Int(randomNumber)] as! GameButton
            } while button.isLocked || button.isMove || button.isAction
            button.setImageAction()
            actionDotsTags.append(Int(randomNumber))
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !LoadingOverlay.shared.isOverlayShown() {
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
                    iAmTheWinner = true
                    sendMovingButton()
                    UIView.animateWithDuration(1.0, animations:{
                        self.movingPoint.frame = CGRectMake(x, y, self.movingPoint.frame.size.width, self.movingPoint.frame.size.height)
                    })
                    UIView.commitAnimations()
                    gameOverWithWinner(winnerPlayer1: true)
                    showEndAlert(winning: true, gaveUp: false,draw: false)
                }
            }
            
        }
    }
    
    /**
    Displays an alert, whether you have won/lost or there is a draw, if the connection has been lost.
    
    :param: winning Bool
    :param: gaveUp  Bool
    :param: draw    Bool
    */
    func showEndAlert(#winning: Bool, gaveUp: Bool, draw: Bool) {
        timer.invalidate()
        progressView.setProgress(1.0, animated: false)
        var message=""
        var title = ""
        
        if draw {
            title = "Bad News 😟"
            message = "You have lost the connection to your opponent, it counts as a draw 🙌"
        }else if winning {
            if gaveUp {
                title = "Congratulation 🍻🎉"
                message = "\(opponentname) gave up! He is such a loser! 😂😂"
            } else {
                title = "Congratulation 🍻🎉"
                message = "You won the game 😏😎"
            }
        } else {
            title = "Bad News Bro 😟"
            message = "You have lost the game 😞. Challenge your buddy in a rematch 😼😼"
        }
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let okAction = UIAlertAction(title: "Ok", style: .Default) { action in
            self.cancelGame()
        }
        
        // Add the actions.
        alertCotroller.addAction(okAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    /**
    Stops the game and jumps back to Rootviewcontroller which is the Homescreen
    */
    func cancelGame(){
        timer.invalidate()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /**
    Sets up the red, moving dot, of the player one.
    */
    func setUpMovingDot(){
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
        
            //gameOverWithWinner(winnerPlayer1: true)
            if !iAmTheWinner {
                showEndAlert(winning: false, gaveUp: false, draw: false)
                gameOverWithWinner(winnerPlayer1: true)
            }
            
            /*
            if !iAmTheWinner{
                showEndAlert(winning: false, gaveUp: false, draw: false)
            } else {
                gameOverWithWinner(winnerPlayer1: true)
            }*/
            UIView.animateWithDuration(1.0, animations:{
                self.movingPoint.frame = CGRectMake(x, y, self.movingPoint.frame.size.width, self.movingPoint.frame.size.height)
            })
            UIView.commitAnimations()
            
        } else {
            //if posofmoving != 0 {
            (mGameButtons[posofmoving] as! GameButton).setImageStandard()
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
            //}

        }
    }
    
    
    func sendAvatar() {
        var json: JSON = [JSON_AVATARID:myavatar,JSON_GAMEID:gameID] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    /**
    Sends the setup of the game. It contains the position of the moving dot, both all the locked dots, the id of the avatar and all the action dots
    */
    func sendGameSetup(){ //movingdot and locked dots and avatarID
        var json: JSON = [JSON_MOVINGDOT:posofmoving,JSON_WINNINGANIMATION:winnerAnimationIndex,JSON_LOCKEDDOTS:lockedDotsTags,JSON_AVATARID:myavatar,JSON_ACTIONDOTS:actionDotsTags,JSON_GAMEID:gameID] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)

        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    /**
    Set all dots to standard
    */
    func resetAllLockedDots() {
        for b in mGameButtons { // reset all locked dots
            var gameButton = b as! GameButton
            if !gameButton.isMove && !gameButton.isAction {
                gameButton.setImageStandard()
            }
        }
    }
    
    /**
    Set all action dots to standard
    */
    func resetAllActionDots() {
        for b in mGameButtons { // reset all locked dots
            var gameButton = b as! GameButton
            if gameButton.isAction {
                gameButton.setImageStandard()
                gameButton.isAction = false
            }
        }
    }
    
    /**
    If a player moves on a action dot, randomly choosen dots gets animated
    
    :param: array of id's of old locked dots
    */
    func animateNewGreyDots(#old: [Int]) {
        var animationDisappear = [Int]()
        for t in old {
            if !lockedDotsTags.contains(t) {
                animationDisappear.append(t)
            }
        }
        for b in mGameButtons {
            if animationDisappear.contains(b.tag-1) {
                newLockedDotAnimation(b as! GameButton)
            }
        }
        
    }
    
    /**
    This method is called, if you receive something through MPC-Framework. This function can decide, whether you're player 1 or 2 and handles so the right actions.
    The data is received in a json.
    
    :param: notification NSNotification
    */
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        
        opponentname = senderPeerId.displayName
        
        let json = JSON(data: receivedData)
        
        var gid = json[JSON_GAMEID].intValue
        if (gid >= gameID - 2) && (gid <= gameID + 2) {
            
            winnerAnimationIndex = json[JSON_WINNINGANIMATION].intValue
            var avatarId = json[JSON_AVATARID].intValue
            if avatarId != 0 {
                opponentsAvatar = avatarId
                avatar2.image = UIImage(named: "avatar\(opponentsAvatar)")
            }
            
            if playernr == 1 { //handle new locked dot
                var pos = json[JSON_MOVINGDOT].intValue
                if pos != 0 && iAmTheWinner == false {
                    posofmoving = pos
                    setUpMovingDot()
                }
                var button: GameButton
                var gaveUp = json[JSON_GIVEUP].boolValue
                if gaveUp {     // player 2 gave up
                    showEndAlert(winning: true, gaveUp: true, draw: false)
                    gameOverWithWinner(winnerPlayer1: true)
                }
                
                if let arrayActionDots = json[JSON_ACTIONDOTS].array {
                    // set action dots
                    if arrayActionDots.count != 0 {
                        resetAllActionDots()
                        actionDotsTags.removeAll(keepCapacity: false)
                        for index in 0...arrayActionDots.count-1 {
                            actionDotsTags.append(arrayActionDots[index].intValue)
                            var button: GameButton
                            button = mGameButtons[arrayActionDots[index].intValue] as! GameButton
                            button.setImageAction()
                        }
                    } else {
                        if actionDotsTags.count == 1 {
                            resetAllActionDots()
                            actionDotsTags.removeAll(keepCapacity: false)
                        }

                    }
                }
                
                //var newpos = json[JSON_NEWLOCKEDDOT].intValue
                var newpos = -1
                if let arraylockedDots = json[JSON_NEWLOCKEDDOT].array {
                    var amountOfNewLockedDots = 0
                    resetAllLockedDots()
                    
                    if arraylockedDots.count < lockedDotsTags.count { // a few green dots disapeard (action field)
                        amountOfNewLockedDots = 100 // -> so don't start the timer and don't hide the overlay
                        var temp = lockedDotsTags
                        lockedDotsTags.removeAll(keepCapacity: false)
                        for x in arraylockedDots {
                            lockedDotsTags.append(x.intValue)
                        }
                        animateNewGreyDots(old: temp)
                    }
                    
                    var reAllocationOfDots = false
                    if arraylockedDots.count == lockedDotsTags.count { // green dots gets reallocated (action field
                        reAllocationOfDots = true   // dots just got reallocated -> don't start timer und don't hide the overlay
                        amountOfNewLockedDots = 0
                        lockedDotsTags.removeAll(keepCapacity: false)
                        for x in arraylockedDots {
                            lockedDotsTags.append(x.intValue)
                        }
                    }
                    
                    for index in 0...arraylockedDots.count-1 {
                        var button: GameButton
                        if arraylockedDots[index] != 100 && !gaveUp { // timeout
                            button = mGameButtons[arraylockedDots[index].intValue] as! GameButton
                            button.setImageLocked()     // set locked dots
                            
                            if !lockedDotsTags.contains(arraylockedDots[index].intValue) {
                                amountOfNewLockedDots++     // new green dot
                                lockedDotsTags.append(arraylockedDots[index].intValue)
                                newLockedDotAnimation(button)
                            }
                        }
                    }
                    newpos = arraylockedDots[arraylockedDots.count-1].intValue
                    // amountOfNewLockedDots = 1 -> 1 normal move (without action field)
                    if newpos != -1 && amountOfNewLockedDots <= 1 && reAllocationOfDots == false {
                        startTimer()    // start timer after adding a new green dot, but not after handling some action fields
                        LoadingOverlay.shared.hideOverlayView()
                        animateMyAvatar()
                    }
                }
                
                var winnerPTwo = json[JSON_WINNERTWO].boolValue
                if winnerPTwo {
                    self.gameOverWithWinner(winnerPlayer1: false)
                    showEndAlert(winning: false, gaveUp: true, draw: false)
                }
            }
            
            if playernr == 2 { //handle pos of moving dot
                posofmoving = json[JSON_MOVINGDOT].intValue
                var gaveUp = json[JSON_GIVEUP].boolValue
                if gaveUp { // player 1 gave up
                    showEndAlert(winning: true, gaveUp: true, draw: false)
                    gameOverWithWinner(winnerPlayer1: false)
                }
                
                if let arrayLockedDots = json[JSON_LOCKEDDOTS].array {
                    // set default locked dots
                    println("jsonlockeddots: \(arrayLockedDots.count)")
                    for index in 0...arrayLockedDots.count-1 {
                        lockedDotsTags.append(arrayLockedDots[index].intValue)
                        var button: GameButton
                        button = mGameButtons[arrayLockedDots[index].intValue] as! GameButton
                        button.setImageLocked()
                    }
                }
                
                if let arrayActionDots = json[JSON_ACTIONDOTS].array {
                    // set action dots
                    resetAllActionDots()
                    actionDotsTags.removeAll(keepCapacity: false)
                    if arrayActionDots.count-1 >= 0 {
                        for index in 0...arrayActionDots.count-1 {
                            actionDotsTags.append(arrayActionDots[index].intValue)
                            var button: GameButton
                            button = mGameButtons[arrayActionDots[index].intValue] as! GameButton
                            button.setImageAction()
                        }
                    }

                }
                
                var amountOfNewLockedDots = 0
                if let arrayLockedDots = json[JSON_NEWLOCKEDDOT].array {
                    resetAllLockedDots()
                    var animationDisappear = [Int]()
                    if arrayLockedDots.count <= lockedDotsTags.count { // a few green dots disapeard or the green dots get reallocated (action field)
                        amountOfNewLockedDots = 100
                        var temp = lockedDotsTags
                        lockedDotsTags.removeAll(keepCapacity: false)
                        for x in arrayLockedDots {
                            lockedDotsTags.append(x.intValue)
                        }
                        animateNewGreyDots(old: temp)
                    }
                    for index in 0...arrayLockedDots.count-1 {
                        var button: GameButton
                        button = mGameButtons[arrayLockedDots[index].intValue] as! GameButton
                        button.setImageLocked()     // set locked dots
                        if !lockedDotsTags.contains(arrayLockedDots[index].intValue) {
                            amountOfNewLockedDots++ // new green dot
                            lockedDotsTags.append(arrayLockedDots[index].intValue)
                            newLockedDotAnimation(button)
                        }
                    }
                }
                //if posofmoving != 0 {
                    setUpMovingDot()
                //}
                
                
                if firstMoveDot{
                    firstMoveDot = false
                }else{
                    // amountOfNewLockedDots = 1 -> 1 normal move (without action field)
                    if amountOfNewLockedDots <= 1 {
                        startTimer() // start timer after adding a new green dot, but not after handling some action fields
                        LoadingOverlay.shared.hideOverlayView()
                        animateMyAvatar()
                    }
                }
            }

            
            
        }
        
    }
    
    /**
    Sends the json with the position of the moving dot. It also sends whether there is a winning index, which means the red dot is moving out of the field. The json also contains whether somebody of the gamer gave up. A game id for synchronisation is also sent.
    */
    func sendMovingButton(){
        var json: JSON = [JSON_MOVINGDOT:posofmoving, JSON_WINNINGANIMATION:winnerAnimationIndex,JSON_GIVEUP:giveUp,JSON_GAMEID:gameID,JSON_ACTIONDOTS:actionDotsTags] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    /**
    Sends the new locked dots.
    
    :param: lockedDots description
    */
    func sendNewLockedDot(lockedDots: [Int]){
        var json: JSON = [JSON_NEWLOCKEDDOT:lockedDots,JSON_AVATARID:myavatar,JSON_WINNERTWO:winnerTwo,JSON_GIVEUP:giveUp,JSON_GAMEID:gameID,JSON_ACTIONDOTS:actionDotsTags] //valid - checked by jsonlint
        var jsonrawdata = json.rawData(options: nil, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(jsonrawdata, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
        
        if error != nil{
            println("Couldn't send message: \(error?.localizedDescription)")
        }
    }
    
    /**
    Sends the cancel the game message.
    */
    func sendCancelGame(){
        let messageDict = [JSON_CANCELGAME:"cancel",JSON_GAMEID:gameID]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
    }
    
    /**
    Generates the locked dots. It depends on how much locked dots you want, but they can be on position 0-64.
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
    
    /**
    Stops the animation of the Player 1 avatar
    */
    func stopAnimating(){
        self.avatar1.layer.removeAllAnimations()
    }
    
    /**
    Starts to animate the avatar of the current player. "wiggle"-Effect.
    */
    func animateMyAvatar() {
        let duration = 0.3
        let options = UIViewKeyframeAnimationOptions.Autoreverse | UIViewKeyframeAnimationOptions.Repeat
        let rotationValue = 0.07
        let rotation = CGFloat(rotationValue)
        
        self.avatar1.transform = CGAffineTransformMakeRotation(-CGFloat(rotationValue/2))
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.avatar1.transform = CGAffineTransformMakeRotation(rotation)
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.avatar1.transform = CGAffineTransformMakeRotation(-rotation)
            })
            }, completion: nil)
    }

    /**
    Handles the action dots. Randomly actions can make a advantage or disadvantage and makes the game more attractive
    
    :param: actionButton GameButton
    */
    func handleActionDots(button: GameButton) {
        
        var rand = arc4random_uniform(UInt32(4))
        
        if rand == 0 {
            
            // grüne dots kommen hinzu
            for i in 0...3 {
                var randomNumber: UInt32 = 0
                var buttonAction: GameButton
                do {
                    randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                    buttonAction = mGameButtons[Int(randomNumber)] as! GameButton
                } while buttonAction.isLocked || buttonAction.isMove || buttonAction.isAction
                var buttonTag = (mGameButtons[Int(randomNumber)] as! GameButton).tag
                lockedDotsTags.append(buttonTag-1)
                (mGameButtons[Int(randomNumber)] as! GameButton).setImageLocked()
                newLockedDotAnimation((mGameButtons[Int(randomNumber)] as! GameButton))
            }
            sendNewLockedDot(lockedDotsTags)
            
        } else if rand == 1 {
            
            // grüne dots explodieren
            for i in 0...3 {
                var randomNumber = arc4random_uniform(UInt32(lockedDotsTags.count - 1))
                for b in mGameButtons {
                    if b.tag-1 == lockedDotsTags[Int(randomNumber)] {
                        var gameButton = b as! GameButton
                        gameButton.setImageStandard()
                        newLockedDotAnimation(gameButton)
                    }
                }
                lockedDotsTags.removeAtIndex(Int(randomNumber))
            }
            sendNewLockedDot(lockedDotsTags)
            
        } else if rand == 2 {
            // grüne dots werden anders angeordnet
            for b in mGameButtons {
                var gameButton = b as! GameButton
                if !gameButton.isMove && !gameButton.isAction {
                    gameButton.setImageStandard()
                }
            }
            for i in 0...lockedDotsTags.count-1 {
                var randomNumber: UInt32 = 0
                var buttonAction: GameButton
                do {
                    randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                    buttonAction = mGameButtons[Int(randomNumber)] as! GameButton
                } while buttonAction.isLocked || buttonAction.isMove || buttonAction.isAction || button.tag == buttonAction.tag
                lockedDotsTags[i] = buttonAction.tag-1
                buttonAction.setImageLocked()
            }
            sendNewLockedDot(lockedDotsTags)
            
        } else if rand == 3 {
            // roter dot wird auf eine zufällige position gesetzt
            var randomNumber: UInt32 = 0
            var buttonAction: GameButton
            do {
                randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                buttonAction = mGameButtons[Int(randomNumber)] as! GameButton
            } while buttonAction.isLocked || buttonAction.isMove || buttonAction.isAction || button.tag == buttonAction.tag
            
            posofmoving = buttonAction.tag-1
            setUpMovingDot()
            if playernr == 2 {
                sendMovingButton()
            } else {
                button.setImageStandard()
            }
        }
    }
    
    /**
    Moves the moving dot to another button, if he is an neighbor
    
    :param: sender UIButton
    */
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
                LoadingOverlay.shared.showOverlay(self.view)
                UIView.animateWithDuration(1.0, animations:{
                    self.movingPoint.frame = CGRectMake(x, y, button.frame.size.width, button.frame.size.height)
                })
                stepcounter++
                mSteps.text = "Steps: \(stepcounter)"
                posofmoving = button.tag - 1
                if button.isAction {
                    handleActionDots(button)
                    button.setImageStandard()
                    button.isAction = false
                    for (index, t) in enumerate(actionDotsTags) {
                        if t == button.tag-1 {
                            actionDotsTags.removeAtIndex(index)
                        }
                    }
                }
                sendMovingButton()
                timer.invalidate()
                progressView.setProgress(1.0, animated: false)
                
            }
        }else{
            if !button.isLocked && button.tag - 1 != posofmoving {
                LoadingOverlay.shared.showOverlay(self.view)
                stepcounter++
                mSteps.text = "Steps: \(stepcounter)"
                
                if button.isAction {
                    handleActionDots(button)
                    button.isAction = false
                    for (index, t) in enumerate(actionDotsTags) {
                        if t == button.tag-1 {
                            actionDotsTags.removeAtIndex(index)
                        }
                    }
                }
                button.setImageLocked()
                newLockedDotAnimation(button)
                if isDotCaged() {
                    winnerTwo = true
                    gameOverWithWinner(winnerPlayer1: false)
                    showEndAlert(winning: true, gaveUp: false, draw: false)
                }
                                lockedDotsTags.append(button.tag-1)
                sendNewLockedDot(lockedDotsTags)
                timer.invalidate()
                progressView.setProgress(1.0, animated: false)
            }
        }
        stopAnimating()
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
    
    /**
    Animates the new locked dot with an scaleeffect
    
    :param: pressed_button GameButton
    */
    func newLockedDotAnimation(button: GameButton) {
        button.transform = CGAffineTransformMakeScale(10, 10)
        UIView.beginAnimations("scale", context: nil)
        UIView.setAnimationDuration(0.8)
        button.transform = CGAffineTransformMakeScale(1.0, 1.0)
        UIView.commitAnimations()
    }
    
    /**
    Checks if the new position of the movingdot is a valid one
    
    :param: x      x position
    :param: y      y position
    :param: button Gamebutton
    
    :returns: bool Yes,No
    */
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
    
    /**
    If there is a winner write the win/lose to core data
    
    :param: winnerPlayer1 Bool, Yes/No
    */
    
    func gameOverWithWinner(#winnerPlayer1: Bool) {
        loadFromCoreData()
        var alreadyInCoreData = false
        for (index, player) in enumerate(players) {
            if opponentname == player.name {
                playerId = index
                alreadyInCoreData = true
            }
        }
        if !alreadyInCoreData {
            var entity = NSEntityDescription.entityForName("Player", inManagedObjectContext:appDelegate.managedObjectContext!)
            var player = Player(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext!)
            player.name = opponentname
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
        let predicate = NSPredicate(format: "name == %@", opponentname)
        
        let fetchRequest = NSFetchRequest(entityName: "Player")
        fetchRequest.predicate = predicate
        
        let fetchedEntities = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Player]
        
        fetchedEntities.first?.wins = players[playerId].wins
        fetchedEntities.first?.amount = players[playerId].amount
        fetchedEntities.first?.lastGame = NSDate()
        
        appDelegate.managedObjectContext!.save(nil)
    }
}