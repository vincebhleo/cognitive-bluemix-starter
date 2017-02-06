//
//  WatsonSTTManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 09/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import Foundation
import SpeechToTextV1

protocol watsonSTTDelegate {
    func sendTranscription(transcription: String?, error:String?)
}

private let watsonSTTManager = WatsonSTTManager()

class WatsonSTTManager: NSObject
{
    var speechToText:SpeechToText!
    var useCustomSTT = false
    var hasResponsePlayed = false
    var isTranscriptionSent = false
    var transcription = ""
    var delegate:watsonSTTDelegate!
    let prefs = UserDefaults.standard
    var username:String!
    var password:String!
    var customizationID:String!
    var isWatsonSTTConfigIncomplete = false
    var isWatsonSTTCustomConfigIncomplete = false
    
    class var sharedInstance: WatsonSTTManager {
        return watsonSTTManager
    }
    
    func initSpeechToText()
    {
        self.speechToText = SpeechToText(username: username, password: password)
    }
    
    func startMicrophone()
    {
        let settings = self.watsonSTTSettings()
        let failure = {
            (error: Error) in
            print("Watson STT : \(error)")
            
            if(self.isTranscriptionSent == false)
            {
                self.isTranscriptionSent = true
                let sttError = error as NSError
                if(sttError.code == Constants.errorCodes.serverDown)
                {
                    self.delegate.sendTranscription(transcription: nil, error: Constants.errorMessages.serverDown)
                }
                else
                {
                    self.delegate.sendTranscription(transcription: nil, error: Constants.errorMessages.somethingWentWrong)
                }
                
            }
        }

        if(useCustomSTT)
        {
            self.speechToText.recognizeMicrophone(settings: settings, model: nil, customizationID: customizationID, learningOptOut: false, compress: true, failure: failure, success: { results in
                self.didReceiveWatsonSTTResponse(results: results,failure: failure)
            })
        }
        else
        {
            self.speechToText.recognizeMicrophone(settings: settings, model: nil, customizationID: nil, learningOptOut: false, compress: true, failure: failure, success: { results in
                self.didReceiveWatsonSTTResponse(results: results,failure: failure)
            })

        }
    }
    
    func stopMicrophone()
    {
        self.speechToText.stopRecognizeMicrophone()
    }
    
    func didReceiveWatsonSTTResponse(results: SpeechRecognitionResults, failure:((NSError) -> Void))
    {
        if let transcription = results.results.first?.alternatives.last?.transcript {
            self.transcription = transcription
        } else {
            if(self.isTranscriptionSent == false)
            {
                self.isTranscriptionSent = true
                self.delegate.sendTranscription(transcription: "", error: nil)
            }
        }
        if ((results.results.first?.final) != nil) {
            if results.results.first!.final {
                
                /*
                 Continuous needs to be set to true , to set inactivityTimeout = -1
                 As continuous is set to true, final = true multiple times, hence
                 add a check if isTranscriptionSent
                 */
                
                if(self.isTranscriptionSent == false)
                {
                    self.isTranscriptionSent = true
                    self.delegate.sendTranscription(transcription: self.transcription,error: nil)
                }
            }
        }
    }
    
    func watsonSTTSettings() -> RecognitionSettings
    {
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        settings.continuous = true
        settings.inactivityTimeout = -1
        return settings
    }
    
    func readCustomSTT()
    {
        let prefs = UserDefaults.standard
        if prefs.bool(forKey: Constants.watsonSTTSettingKeys.customSttPreference) == true {
            print("Custom STT On")
            useCustomSTT = true
            customizationID = prefs.string(forKey: Constants.watsonSTTSettingKeys.customizationId)
            
            if(customizationID == "")
            {
                self.isWatsonSTTCustomConfigIncomplete = true
            }
            else
            {
                self.isWatsonSTTCustomConfigIncomplete = false
            }
            
        } else {
            print("Custom STT Off")
            useCustomSTT = false
            self.isWatsonSTTCustomConfigIncomplete = false
        }
    }
    
    func readWatsonSTTCreds()
    {
        let prefs = UserDefaults.standard
        username = prefs.string(forKey: Constants.watsonSTTSettingKeys.username)
        password = prefs.string(forKey: Constants.watsonSTTSettingKeys.password)
        
        if(username == "" || password == "")
        {
            self.isWatsonSTTConfigIncomplete = true
        }
        else
        {
            self.isWatsonSTTConfigIncomplete = false
        }
    }
}
    
