//
//  MPCHandler.swift
//  Semesterprojekt_DOT
//
//  Created by Mario Baumgartner on 30.05.15.
//  Copyright (c) 2015 Mario Baumgartner. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreBluetooth


class MPCHandler: NSObject, MCSessionDelegate, CBPeripheralManagerDelegate {
    
    var myBTManager : CBPeripheralManager?
    
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil
    
    func setupPeriphial(){
        myBTManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    //BT Manager
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var state = -1
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            state = 1 //Bluetooth is on
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            state = 0 //Bluetooth is on
        } else if peripheral.state == CBPeripheralManagerState.Unsupported {
            state = -1
        } else if peripheral.state == CBPeripheralManagerState.Unauthorized {
            state = -1
        }
        
        let userInfo = ["state":state]
        NSNotificationCenter.defaultCenter().postNotificationName("MPC_BluetoothStateChanged", object: nil, userInfo: userInfo)
        
    }
    
    func setupPeerWithDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession(){
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrowser(){
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
        
    }
    
    func advertiseSelf(advertise:Bool){
        if advertise{
            advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
            advertiser!.start()
        }else{
            advertiser!.stop()
            advertiser = nil
        }
    }
    
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        let userInfo = ["peerID":peerID,"state":state.rawValue]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidChangeStateNotification", object: nil, userInfo: userInfo)
        })
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let userInfo = ["data":data, "peerID":peerID]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidReceiveDataNotification", object: nil, userInfo: userInfo)
        })
        
    }
    
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
}

