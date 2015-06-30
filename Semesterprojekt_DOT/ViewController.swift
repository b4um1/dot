//
//  ViewController.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 30.05.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import iAd

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}

class ViewController: UIViewController, MCBrowserViewControllerDelegate {

    @IBOutlet weak var label_pairedpartner: UILabel!
    @IBOutlet weak var extremeModeSwitch: UISwitch!
    @IBOutlet var connectionLight: UIButton!
    
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
        player = 1
        println("Anzahl viewcontroller home: \(self.navigationController?.viewControllers.count)");
        
//        if !oppenentname.isEmpty {
//            animateBulb()
//            animateText()
//        }
    }
    @IBAction func disconnectMe(sender: AnyObject) {
        var connectedPeers = appDelegate.mpcHandler.session.connectedPeers.count
        
        println("Disconnect me! \(connectedPeers)")
        if connectedPeers > 0 {
            appDelegate.mpcHandler.session.disconnect()
            appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
            appDelegate.mpcHandler.setupSession()
            appDelegate.mpcHandler.advertiseSelf(true)
        }
        
        println("peers: \(appDelegate.mpcHandler.session.connectedPeers.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.canDisplayBannerAds = true
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
            println("id: \(defaults.integerForKey(avatarKey))")
        }
    }
    
    /*
    If the app terminates, close the actual session
    */
    func appwillterminate(){
        appDelegate.mpcHandler.session.disconnect();
    }
    
    
    
    func peerChangedStateWithNotification(notification:NSNotification){
        //appDelegate.mpcHandler.session.connectedPeers[0].disconnect
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        let peerid = userInfo.objectForKey("peerID") as! MCPeerID
        
        oppenentname = peerid.displayName
        
        if state == MCSessionState.Connecting.rawValue{
            self.label_pairedpartner.text = "Connecting with \(oppenentname)..."
        }
        var frameConnectionLight = CGRect()
        var frameLabel = CGRect()
        if state == MCSessionState.Connected.rawValue{ //toRaw was replaced with rawValue
            self.label_pairedpartner.text = "Connected with \(oppenentname)"
            self.connectionLight.setImage(UIImage(named:"Lighting_Bulb_connected"), forState: .Normal)
            
            frameConnectionLight = connectionLight.layer.frame
            frameLabel = label_pairedpartner.layer.frame
            
            animateText()
            animateBulb()
            
        }else{
            oppenentname = ""
            self.label_pairedpartner.text = "Disconnected"
            self.connectionLight.setImage(UIImage(named:"Lighting_Bulb_disconnected"), forState: .Normal)
            self.connectionLight.layer.removeAllAnimations()
            self.connectionLight.layer.frame = frameConnectionLight
            self.label_pairedpartner.layer.frame = frameLabel
        }
    }
    
    func animateText() {
        let duration = 2.0
        let options = UIViewKeyframeAnimationOptions.Autoreverse | UIViewKeyframeAnimationOptions.Repeat
        let rotationValue = 0.07
        let rotation = CGFloat(rotationValue)
        
        label_pairedpartner.transform = CGAffineTransformMakeTranslation(-10, 0)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in

                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(-10, 0)

            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            }, completion: nil)

        
        label_pairedpartner.transform = CGAffineTransformMakeTranslation(0, 0)
        
        UIView.animateKeyframesWithDuration(4.0, delay: 0.0, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.01, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.7, relativeDuration: 0.01, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(-3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.01, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.9, relativeDuration: 0.01, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(-3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(1.0, relativeDuration: 0.01, animations: { () -> Void in
                self.label_pairedpartner.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            }, completion: nil)

        
    }
    
    func animateBulb() {
        let duration = 0.3
        let options = UIViewKeyframeAnimationOptions.Autoreverse | UIViewKeyframeAnimationOptions.Repeat
        let rotationValue = 0.07
        let rotation = CGFloat(rotationValue)
        
        connectionLight.transform = CGAffineTransformMakeRotation(-CGFloat(rotationValue/2))
        connectionLight.transform = CGAffineTransformMakeScale(1.2, 1.2)
        
        self.connectionLight.clipsToBounds = true
        self.connectionLight.enabled = true
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.connectionLight.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.connectionLight.transform = CGAffineTransformMakeRotation(rotation)
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.connectionLight.transform = CGAffineTransformMakeScale(1, 1)
                self.connectionLight.transform = CGAffineTransformMakeRotation(-rotation)
            })
            }, completion: nil)
        
    }
    
    func bluetoothStateDidChange(notification: NSNotification){ //1 on 0 off
        let info = NSDictionary(dictionary: notification.userInfo!)
        let state = info.objectForKey("state") as! Int
        
        switch(state){
        case 0:
            //appDelegate.mpcHandler.session.disconnect()
            break
        default:
            break
        }
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData

        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        
        if message.objectForKey("string")?.isEqualToString("StartNewGameFromHome") == true{
            player = 2;
            self.performSegueWithIdentifier(segueStartGame, sender: nil)
        }
    }

    @IBAction func startNewGame(sender: AnyObject) {
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
    
    func sendGameStartJson(){
        let messageDict = ["string":"StartNewGameFromHome"]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueStartGame{
            let controller = segue.destinationViewController as! GameScreenViewController
            controller.opponentname = self.oppenentname
            controller.stepcounter = 0
            controller.playernr = self.player
            controller.appDelegate = self.appDelegate
            controller.isExtremeMode = extremeModeSwitch.on
           
            let start = NSDate(dateString:"2015-01-01")
            let enddt = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let datecomponenets = calendar.components(NSCalendarUnit.CalendarUnitSecond, fromDate: start, toDate: enddt, options: nil)
            let seconds = datecomponenets.second
            println("Seconds: \(seconds)")
            
            controller.gameID = seconds
        }else if segue.identifier == "showHallOfFame" {
            let destination = segue.destinationViewController as! HallOfFameViewController
            destination.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Automatic
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var shouldperform = true;
        
        println("Connected peers: \(appDelegate.mpcHandler.session.connectedPeers.count)")
        
        
        //check if there is any connected device
        if identifier == segueStartGame{
            if appDelegate.mpcHandler.session.connectedPeers.count == 0{
                shouldperform = false
                startConnectionBrowser()
            } else {
                sendGameStartJson()
            }
        }
        return shouldperform
    }

}

