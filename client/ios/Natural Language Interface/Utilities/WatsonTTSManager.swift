//
//  WatsonTTSManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 11/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import Foundation
import TextToSpeechV1

protocol watsonTTSDelegate {
    func playWavData(data: NSData?, error:String?)
}

private let watsonTTSManager = WatsonTTSManager()

class WatsonTTSManager: NSObject
{
    var textToSpeech:TextToSpeech!
    var delegate:watsonTTSDelegate!
    var username:String!
    var password:String!
    var isWatsonTTSConfigIncomplete = false
    
    class var sharedInstance: WatsonTTSManager {
        return watsonTTSManager
    }
    
    func initTextToSpeech()
    {
        self.textToSpeech = TextToSpeech(username: username, password: password)
    }
    
    func convertTextToSpeech(text:String)
    {
        self.textToSpeech.synthesize(text, voice: SynthesisVoice.us_Michael.rawValue, customizationID: nil, audioFormat: AudioFormat.wav,
        failure:
        {
                error in print("error was generated \(error)")
                self.delegate.playWavData(data: nil, error: Constants.errorMessages.somethingWentWrong)
        })
        {
            data in
            self.delegate.playWavData(data: data as NSData?, error: nil)
        }
    }
    
    func readWatsonTTSCreds()
    {
        let prefs = UserDefaults.standard
        username = prefs.string(forKey: Constants.watsonTTSSettingKeys.username)
        password = prefs.string(forKey: Constants.watsonTTSSettingKeys.password)
        
        if(username == "" || password == "")
        {
            self.isWatsonTTSConfigIncomplete = true
        }
        else
        {
            self.isWatsonTTSConfigIncomplete = false
        }
    }
}

