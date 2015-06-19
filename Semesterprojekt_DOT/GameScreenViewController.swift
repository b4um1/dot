//
//  GameScreenViewController.swift
//  Semesterprojekt_DOT
//
//  Created by User on 05/06/15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameScreenViewController: UIViewController {

    @IBOutlet weak var mOpponent: UILabel!
    @IBOutlet weak var mSteps: UILabel!
    @IBOutlet weak var mTurn: UILabel!
    @IBOutlet weak var startingPoint: GameButton!
    @IBOutlet weak var movingPoint: GameButton!
    @IBOutlet var mGameButtons: [UIButton]!
    
    var lockedDotsTags = [Int]()
    let numberOfDefaultLockedDots = 20
    var appDelegate: AppDelegate! //appdelegate for communication with the mpc handler
    var oppenentname = ""   // name of the opponent
    var playernr = 0      // you are player 1 for standard
    var stepcounter = 0     // counts the steps made by gamer 1
    
    var posofmoving = 0
    var winnerAnimationIndex = 0    // should the dot move up, down, left, right?
    var firstConnection = true, firstMoveDot = true
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        initGameScreen()
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    func initGameScreen() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        mOpponent.text = "Opponet: \(oppenentname)"
        mSteps.text = "Steps: \(stepcounter)"
        
        for b in mGameButtons { // hide all buttons because of the animation
            b.hidden = true
        }
        
        if playernr == 1{
            mTurn.text = "Player 1 - It's your turn";
            posofmoving = 28
            (mGameButtons[posofmoving] as! GameButton).isMove = true
            generateLockedDots()
            sendLockedButtons()
            sendMovingButton()
        }else{
            mTurn.text = "Player 2 - Wait until your opponent has done his turn"
            LoadingOverlay.shared.showOverlay(self.view)
        }

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
        
        let alertCotroller = UIAlertController(title: title, message: "play again?", preferredStyle: .Alert)
        
        // Create the actions.
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
            self.clearGameSettings(true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .Default) { action in
            self.clearGameSettings(false)
        }
        
        // Add the actions.
        alertCotroller.addAction(yesAction)
        alertCotroller.addAction(noAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func clearGameSettings(player1: Bool) {

    }
    

    
    override func viewDidLayoutSubviews() {
        if playernr == 1 {
            setUpMovingDot()
        }else{//player 2
            
        }
       
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
            showEndAlert(false)
            UIView.animateWithDuration(1.0, animations:{
                self.movingPoint.frame = CGRectMake(x, y, self.movingPoint.frame.size.width, self.movingPoint.frame.size.height)
            })
            UIView.commitAnimations()
            
        } else {
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
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        oppenentname = senderPeerId.displayName
        
        if playernr == 1 { //handle new locked dot
            let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
            
            var button: GameButton
            var newpos = message.objectForKey("newlockeddot")!.integerValue
            button = mGameButtons[newpos] as! GameButton
            button.setImageLocked()
            newLockedDotAnimation(button)
            LoadingOverlay.shared.hideOverlayView()
        }
        
        if playernr == 2 { //handle pos of moving dot
            
            
            
            /*if firstConnection { //in this part, the array of locked dots is received
                firstConnection = false
                let data = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil)
                
                if let arrayLockedDot = data as? Array<Int> {
                    for index in 0...arrayLockedDot.count-1 {
                        var button: GameButton
                        button = mGameButtons[arrayLockedDot[index]] as! GameButton
                        button.setImageLocked()
                    }
                }
                
            } else {
                let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                winnerAnimationIndex = message.objectForKey("winnerAnimationIndex")!.integerValue
                
                posofmoving = message.objectForKey("movingdot")!.integerValue
                setUpMovingDot()
                if firstMoveDot{
                    firstMoveDot = false
                }else{
                    LoadingOverlay.shared.hideOverlayView()
                }
            }*/
        }
    }
    
    func sendMovingButton(){
        let messageDict = ["movingdot":"\(posofmoving)", "winnerAnimationIndex":"\(winnerAnimationIndex)"]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }

    }
    func sendLockedButtons(){
        
        let data = NSJSONSerialization.dataWithJSONObject(lockedDotsTags, options: nil, error: nil)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        println("String jsonformat: \(string)")
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(data, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        
    }
    
    func sendGameSetup(){ //movingdot and  locked dots
        
    }
    
    
    func sendNewLockedDot(posoflocked: Int){
        let messageDict = ["newlockeddot":"\(posoflocked)"]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
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
}
