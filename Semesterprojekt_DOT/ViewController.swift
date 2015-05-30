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
    
    var test = 0; //Testvariable
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothStateDidChange:", name: "MPC_BluetoothStateChanged", object: nil)
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        let peerid = userInfo.objectForKey("peerID") as! MCPeerID
        
        if state == MCSessionState.Connecting.rawValue{
            self.label_pairedpartner.text = "Connecting with \(peerid.displayName)..."
        }
        if state == MCSessionState.Connected.rawValue{ //toRaw was replaced with rawValue
            self.label_pairedpartner.text = "Connected with \(peerid.displayName)"
        }else{
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
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.objectForKey("string")?.isEqualToString("New Game") == true{
            let alert = UIAlertController(title: "TicTacToe", message: "\(senderDisplayName) has started a new Game", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
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


}

