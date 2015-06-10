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
    let numberOfDefaultLockedDots = 10
    var appDelegate: AppDelegate! //appdelegate for communication with the mpc handler
    var oppenentname = ""   // name of the opponent
    var playernr = 0      // you are player 1 for standard
    var stepcounter = 0     // counts the steps made by gamer 1
    
    var posofmoving = 0
    var firstConnection = true, firstMoveDot = true

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        mOpponent.text = "Opponet: \(oppenentname)"
        mSteps.text = "Steps: \(stepcounter)"
        
        for b in mGameButtons { // hide all buttons because of the animation
            b.hidden = true
        }
        
        if playernr == 1{
            mTurn.text = "Player 1 - It's your turn";
            posofmoving = 28
            generateLockedDots()
            sendLockedButtons()
            sendMovingButton()
        }else{
            mTurn.text = "Player 2 - Wait until your opponent has done his turn"
            LoadingOverlay.shared.showOverlay(self.view)
        }
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
    
    override func viewDidLayoutSubviews() {
        if playernr == 1 {
            setUpMovingDot()
        }else{//player 2
            
        }
       
    }
    
    func setUpMovingDot(){
        //set up the button where player 1 starts -- should happen randomly
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
            
            LoadingOverlay.shared.hideOverlayView()
        }
        
        if playernr == 2 { //handle pos of moving dot
            if firstConnection { //in this part, the array of locked dots is received
                firstConnection = false
                let data = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil)
                
                if let arrayLockedDot = data as? Array<Int> {
                    for index in 0...arrayLockedDot.count-1 {
                        var button: GameButton
                        button = mGameButtons[arrayLockedDot[index]] as! GameButton
                        button.setImageLocked()
                    }
                }
                
            }else{
                let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                posofmoving = message.objectForKey("movingdot")!.integerValue
                setUpMovingDot()
                if firstMoveDot{
                    firstMoveDot = false
                }else{
                    LoadingOverlay.shared.hideOverlayView()
                }
                
            }
        }
    }
    
    func sendMovingButton(){
        let messageDict = ["movingdot":"\(posofmoving)"]
        
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
            } while button.isLocked
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
            if !button.isLocked{
                stepcounter++
                mSteps.text = "Steps: \(stepcounter)"
                button.setImageLocked()
                sendNewLockedDot(button.tag-1)
                LoadingOverlay.shared.showOverlay(self.view)
            }
        }
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
                if (b as! GameButton).isLocked {
                    return false
                }
            }
        }
        return isValid
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
