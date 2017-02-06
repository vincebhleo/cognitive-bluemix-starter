//
//  MQTTManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 18/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import UIKit
import Foundation
import MQTTFramework

protocol mqttDelegate {
    func commandReceived(message:String)
}

private let mqttManager = MQTTManager()

class MQTTManager: NSObject, MQTTSessionDelegate {

    var mqttSession: MQTTSession?
    var orgId:String = ""
    var deviceType:String = ""
    var deviceId:String = ""
    var password:String = ""
    var delegate:mqttDelegate!
    var isMQTTConfigIncomplete = false
    
    class var sharedInstance: MQTTManager {
        return mqttManager
    }
    
    func initMQTT() {
        
        let clientIdPid = "d:\(orgId):\(deviceType):\(deviceId)"
        
        mqttSession = MQTTSession(
            clientId: clientIdPid,
            userName: Constants.mqttConfigSettings.username,
            password: password,
            keepAlive: UInt16(Constants.mqttConfigSettings.keepAlive),
            cleanSession: true,
            will: false,
            willTopic: nil,
            willMsg: nil,
            willQoS: .atMostOnce,
            willRetainFlag: false,
            protocolLevel: 4,
            runLoop: nil,
            forMode: nil
        )
        
        mqttSession!.delegate = self
        mqttSession!.persistence.persistent = false
        mqttSession!.connect(toHost: "\(orgId)\(Constants.mqttConfigSettings.serverAddress)", port: UInt32(Constants.mqttConfigSettings.serverPort), usingSSL: false)
        
    }
    
    func createTextMessage(text:String) -> Data
    {
        
        let messageDict:Dictionary = ["d":[Constants.mqttJsonKeys.jsonText:text,Constants.mqttJsonKeys.latText:LocationManager.sharedInstance.currentLocation?.coordinate.latitude ?? 0,Constants.mqttJsonKeys.longText:LocationManager.sharedInstance.currentLocation?.coordinate.longitude ?? 0]]
        let messageData:Data = try! JSONSerialization.data(withJSONObject: messageDict as Any, options: [])
        return messageData
    }
    
    func publish(topic:String, message:Data)
    {
        let dataString = NSString(data: message, encoding: String.Encoding.utf8.rawValue)!
        print(" publish \(dataString)")
        mqttSession?.publishData(message,
                                 onTopic: topic,
                                 retain: false,
                                 qos: MQTTQosLevel.atMostOnce)
    }
    
    func subscribeToTopic(topic:String)
    {
        print(" subscribe \(topic)")
        let handler:MQTTSubscribeHandler = {
            (error: Error?, number:[NSNumber]?) in
            
            if(error != nil)
            {
                print("Subscribe : \(error)")
            }
            
        }
        mqttSession?.subscribe(toTopic: topic, at: MQTTQosLevel.atMostOnce, subscribeHandler: handler)
    }
    
    func readMQTTConfig()
    {
        let prefs = UserDefaults.standard
        orgId = prefs.string(forKey: Constants.mqttConfigSettingKeys.orgId)!
        deviceType = prefs.string(forKey: Constants.mqttConfigSettingKeys.deviceType)!
        deviceId = prefs.string(forKey: Constants.mqttConfigSettingKeys.deviceId)!
        password = prefs.string(forKey: Constants.mqttConfigSettingKeys.password)!
        
        if(orgId == "" || deviceType == "" || deviceId == "" || password == "")
        {
            self.isMQTTConfigIncomplete = true
        }
        else
        {
            self.isMQTTConfigIncomplete = false
        }
    }
    
    // MARK: - MQTTSessionDelegate methods
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        print(" handle event: event code \(eventCode.rawValue) not handled")
    }
    
    func connected(_ session: MQTTSession!) {
        print(" connected session: \(session.clientId)")
    }
    
    func connected(_ session: MQTTSession!, sessionPresent: Bool) {
        print(" connected session: \(session.clientId), sessionPresent \(sessionPresent)")
        MQTTManager.sharedInstance.subscribeToTopic(topic: Constants.mqttJsonKeys.subscribeTopic)
    }
    
    func connectionRefused(_ session: MQTTSession!, error: Error!) {
        print(" connection refused \(error)")
        print("connectionRefused: turning off MQTT")
    }
    
    func connectionClosed(_ session: MQTTSession!) {
        print(" connection closed")
    }
    
    func connectionError(_ session: MQTTSession!, error: Error!) {
        print(" connection error \(error)")
    }
    
    func protocolError(_ session: MQTTSession!, error: Error!) {
        print(" protocol error \(error)")
    }
    
    func messageDelivered(_ session: MQTTSession!, msgID: UInt16) {
        print(" message delivered \(msgID)")
    }
    
    func session(_ session: MQTTSession!, newMessage data: Data!, onTopic topic: String!) {
        print("rec mesg")
    }
    
    func subAckReceived(_ session: MQTTSession!, msgID: UInt16, grantedQoss qoss: [NSNumber]!) {
        print(" subAck received \(msgID)")
    }
    
    func unsubAckReceived(_ session: MQTTSession!, msgID: UInt16) {
        print(" unsubAck received \(msgID)")
    }
    
    func sending(_ session: MQTTSession!, type: MQTTCommandType, qos: MQTTQosLevel, retained: Bool, duped: Bool, mid: UInt16, data: Data!) {
        print(" sending")
    }
    
    func received(_ session: MQTTSession!, type: MQTTCommandType, qos: MQTTQosLevel, retained: Bool, duped: Bool, mid: UInt16, data: Data!) {
        let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        print(dataString ?? "")
    }
    
    func buffered(_ session: MQTTSession!, queued: UInt, flowingIn: UInt, flowingOut: UInt) {
        print(" buffered")
    }
    
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        print("new message")
        
        if(data != nil)
        {
            let json:[String : AnyObject] = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            print(json["d"] ?? "")
            if let mesg = json["d"] as? String
            {
                self.delegate.commandReceived(message: mesg)
            }
            else
            {
                self.delegate.commandReceived(message: "")
            }
        }
        else
        {
            self.delegate.commandReceived(message: "")
        }
    }

}
