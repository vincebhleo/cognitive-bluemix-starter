//
//  Constants.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 09/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import Foundation
import UIKit

struct Constants
{
    struct iOSVersions
    {
        static let iOS10:String = "10.0"
    }
    
    struct localeIdentifiers
    {
        static let enUs:String = "en-US"
    }
    
    struct errorCodes
    {
        static let serverDown:Int = -6003
    }
    
    struct errorMessages
    {
        static let serverDown:String = "Server is down, please try again later"
        static let somethingWentWrong:String = "Something went wrong"
        static let configIncomplete:String = "Please make sure you have set all the configurations in Settings required to use "
        static let watsonSTTConfigIncomplete = "Watson STT"
        static let watsonSTTCustomConfigIncomplete = "Watson Custom STT"
        static let watsonTTSConfigIncomplete = "Watson TTS"
        static let mqttConfigIncomplete = "Watson IOT"
        static let mesgSeperatorComma = " , "
        static let mesgSeperatorAnd = " & "
    }
    
    struct messages
    {
        static let settingsSaved:String = "Settings saved successfully"
    }
    
    struct conversationImageNames
    {
        static let requestBubble = "requestBubble"
        static let responseBubble = "responseBubble"
    }
    
    struct speakerIconImageNames
    {
        static let speakerIcon = "speakerIcon"
        static let speakerIconHighlighted = "speakerIconHighlighted"
    }
    
    struct logoImageNames
    {
        static let logoPng = "logo.png"
        static let logo = "logo"
    }
    
    struct logoImageSize
    {
        static let iPhoneWidth:CGFloat = 30
        static let iPhoneHeight:CGFloat = 30
        static let iPadWidth:CGFloat = 50
        static let iPadHeight:CGFloat = 50
    }
    
    struct mqttConfigSettings
    {
        static let keepAlive:Int = 3000
        static let serverAddress:String = ".messaging.internetofthings.ibmcloud.com"
        static let serverPort:Int = 1883
        static let username:String = "use-token-auth"
    }
    
    struct mqttJsonKeys
    {
        static let jsonText:String = "text"
        static let latText:String = "lat"
        static let longText:String = "long"
        static let publishTopic:String = "iot-2/evt/text/fmt/json"
        static let subscribeTopic:String = "iot-2/cmd/+/fmt/json"
    }
    
    struct mqttConfigSettingKeys
    {
        static let iotServerAddress:String = "iot_server_address"
        static let iotServerPort:String = "iot_server_port"
        static let orgId:String = "org_id"
        static let deviceType:String = "device_type"
        static let deviceId:String = "device_id"
        static let username:String = "mqtt_username"
        static let password:String = "mqtt_password"
    }
    
    struct watsonSTTSettingKeys
    {
        static let username:String = "watson_stt_username"
        static let password:String = "watson_stt_password"
        static let customSttPreference:String = "custom_stt_preference"
        static let customizationId:String = "watson_stt_customization_id"
    }
    
    struct watsonTTSSettingKeys
    {
        static let username:String = "watson_tts_username"
        static let password:String = "watson_tts_password"
    }
    
    struct themeSettingKeys
    {
        static let hexColorCode:String = "theme_hex_color_code"
        static let title:String = "app_title"
    }
    
    struct buildSettingKeys
    {
        static let version:String = "version"
        static let buildNo:String = "build_no"
    }
    
    struct chatBubbleDimensions
    {
        static let lastChatBubbleY:CGFloat = 10.0
        static let internalPadding:CGFloat = 25.0
    }
    
    struct colors
    {
        static let defaultTheme:String = "2DCCD3"
    }
    
    struct theme
    {
        static let defaultTitle:String = "Natural Language Interface"
    }
}
