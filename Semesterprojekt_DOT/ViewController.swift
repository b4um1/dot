//
//  ViewController.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 30.05.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {

    @IBOutlet weak var label_pairedpartner: UILabel!
    
    let segueStartGame = "startGameScreen"
    var player = 1; //Testvariable
    var appDelegate: AppDelegate!
    var newGame:Bool = false
    var oppenentname = ""
    let defaults = NSUserDefaults.standardUserDefaults()

    let numberOfAvatars = 40
    let avatarKey = "avatarId"
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.hidden = true
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothStateDidChange:", name: "MPC_BluetoothStateChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appwillterminate:", name: "APP_WILL_TERMINATE", object: nil)

        
        var id = defaults.integerForKey(avatarKey)
        if id == 0 {
            defaults.setObject(Int(arc4random_uniform(UInt32(numberOfAvatars)) + 1), forKey: avatarKey)
        }
    }
    
    /*
    If the app terminates, close the actual session
    */
    func appwillterminate(){
        appDelegate.mpcHandler.session.disconnect();
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        let peerid = userInfo.objectForKey("peerID") as! MCPeerID
        
        oppenentname = peerid.displayName
        
        if state == MCSessionState.Connecting.rawValue{
            self.label_pairedpartner.text = "Connecting with \(oppenentname)..."
        }
        if state == MCSessionState.Connected.rawValue{ //toRaw was replaced with rawValue
            self.label_pairedpartner.text = "Connected with \(oppenentname)"
        }else{
            oppenentname = ""
            self.label_pairedpartner.text = "Disconnected"
        }
        
    }
    
    func bluetoothStateDidChange(notification: NSNotification){ //1 on 0 off
        let info = NSDictionary(dictionary: notification.userInfo!)
        let state = info.objectForKey("state") as! Int
        
        switch(state){
        case 0:
            appDelegate.mpcHandler.session.disconnect()
            break
        default:
            break
        }
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        if newGame == false {
            newGame = true
            let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
            let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
            oppenentname = senderPeerId.displayName
            
            if message.objectForKey("string")?.isEqualToString("New Game") == true{
                player = 2;
                self.performSegueWithIdentifier(segueStartGame, sender: nil)
            }

        }
        
    }

    @IBAction func startNewGame(sender: AnyObject) {
        println("Message has been sent");
        
        let messageDict = ["string":"New Game"]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
    @IBAction func connectWithOpponentPlayer(sender: AnyObject) {
        startConnectionBrowser()
    }
    
    func startConnectionBrowser(){
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueStartGame{
            let controller = segue.destinationViewController as! GameScreenViewController
            controller.oppenentname = self.oppenentname
            controller.stepcounter = 0
            controller.playernr = self.player
            controller.appDelegate = self.appDelegate
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var shouldperform = true;
        
        if identifier == segueStartGame{
            if oppenentname.isEmpty{
                //shouldperform = false
                //startConnectionBrowser()
            }
        }
        return shouldperform
    }

}

