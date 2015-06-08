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

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        mOpponent.text = "Opponet: \(oppenentname)"
        mSteps.text = "Steps: \(stepcounter)"
        
        if playernr == 1{
            mTurn.text = "Player 1 - It's your turn";
            posofmoving = 30
            generateLockedDots()
            sendData()
        }else{
            mTurn.text = "Player 2 - Wait until your opponent has done his turn";
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
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        oppenentname = senderPeerId.displayName
        
        if playernr == 2 {
            posofmoving = message.objectForKey("movingdot")!.integerValue
            setUpMovingDot()
        }
    }
    
    func sendData(){
        let messageDict = ["movingdot":"\(posofmoving)"]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }

    }

    
    func generateLockedDots(){
        for i in 0...numberOfDefaultLockedDots {
            var button: GameButton
            var randomNumber:UInt32 = 0
            do {
                randomNumber = arc4random_uniform(UInt32(mGameButtons.count - 1))
                println(randomNumber)
                button = mGameButtons[Int(randomNumber)] as! GameButton
            } while button.isLocked
            button.setImageLocked()
            lockedDotsTags.append(Int(randomNumber))
        }

    }

    
    @IBAction func onButtonPressed(sender: AnyObject) {
        var button = sender as! GameButton
        println("#:\(button.tag) origin: \(button.frame.origin)")
        
        /*
        // alt:
        UIView.animateWithDuration(1.0, animations:{
            self.movingPoint.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height)
        })
        */
        
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
            sendData()
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
