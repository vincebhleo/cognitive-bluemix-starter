//
//  SettingsUtils.swift
//  askOlli
//
//  Created by Troy Dugger on 7/11/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

struct SettingsUtils {

    /// go through Info.plist and get the version and build number and add to Settings.bundle
    static func putVersionAndBuildnumInSettings() {
        
        if let appInfo = Bundle.main.infoDictionary {
            if let version = appInfo["CFBundleShortVersionString"] as? String {
                if let buildnum = appInfo["CFBundleVersion"] as? String {
                    
                    let defaults = UserDefaults.standard
                    defaults.set(version, forKey: Constants.buildSettingKeys.version)
                    defaults.set(buildnum, forKey: Constants.buildSettingKeys.buildNo)
                    //defaults.synchronize()
                }
            }
        }
    }
    
    /// go through all the preferences that have DefaultValue and register them
    static func registerDefaultsForUserDefaults() {
        
        // setup user preference defaults from the Root.plist

        var defaultDict = [String : AnyObject]()
        for itemDict in getArrayOfPreferencesFromRootPlist() {
            if let defaultValue = (itemDict as AnyObject).object(forKey: "DefaultValue") {
                if let key = (itemDict as AnyObject).object(forKey: "Key") as? String {
                    defaultDict[key] = defaultValue as AnyObject?
                }
            }
        }
        UserDefaults.standard.register(defaults: defaultDict)
    }
    
    /// go through all the preferences that have titles and look for the value provided to find the corresponding title
    static func getTitleForPreferenceValue(key: String, value: String) -> String {
        
        for itemDict in getArrayOfPreferencesFromRootPlist() {
            if let aKey = (itemDict as AnyObject).object(forKey: "Key") as? String {
                if aKey == key {
                    if let values = (itemDict as AnyObject).object(forKey: "Values") as? [String], let titles = (itemDict as AnyObject).object(forKey: "Titles") as? [String] {
                        var indexCount = 0
                        for aValue in values {
                            if aValue == value {
                                return titles[indexCount]
                            }
                            indexCount += 1
                        }
                    }
                }
            }
        }


        // TODO: this messages should go to debug output
        print("getTitleForPreferenceValue: Unable to find title for key \(key) with value \(value), check Root.plist")
        return "Unknown Title"
    }
    
    /// get all the preferences from Root.plist in Settings.bundle
    static func getArrayOfPreferencesFromRootPlist() -> NSArray {
        
        if let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle") {
            let settingsBundle = Bundle.init(path: bundlePath)
            if let rootPlistPath = settingsBundle?.path(forResource: "Root", ofType: "plist") {
                let settingsDict = NSDictionary.init(contentsOfFile: rootPlistPath)
                if let settingsItems = settingsDict?.object(forKey: "PreferenceSpecifiers") as? NSArray {
                    return settingsItems
                } else {
                    print("getArrayOfPreferencesFromRootPlist: no preferences found in Root.plist")
                }
            } else {
                print("getArrayOfPreferencesFromRootPlist: no Root.plist found")
            }
        } else {
            print("getArrayOfPreferencesFromRootPlist: no Settings.bundle found")
        }
        print("getArrayOfPreferencesFromRootPlist: Unable to get settings, is there a Root.plist?")
        return []
    }
    
    static func initSettings()
    {
        let prefs = UserDefaults.standard
        
        // Watson STT
        if (prefs.value(forKey: Constants.watsonSTTSettingKeys.username) == nil)
        {
            prefs.setValue("", forKey: Constants.watsonSTTSettingKeys.username)
        }
        if (prefs.value(forKey: Constants.watsonSTTSettingKeys.password) == nil)
        {
            prefs.setValue("", forKey: Constants.watsonSTTSettingKeys.password)
        }
        if (prefs.value(forKey: Constants.watsonSTTSettingKeys.customSttPreference) == nil)
        {
            prefs.set(false, forKey: Constants.watsonSTTSettingKeys.customSttPreference)
        }
        if (prefs.value(forKey: Constants.watsonSTTSettingKeys.customizationId) == nil)
        {
            prefs.setValue("", forKey: Constants.watsonSTTSettingKeys.customizationId)
        }
        
        // Watson TTS
        if (prefs.value(forKey: Constants.watsonTTSSettingKeys.username) == nil)
        {
            prefs.setValue("", forKey: Constants.watsonTTSSettingKeys.username)
        }
        if (prefs.value(forKey: Constants.watsonTTSSettingKeys.password) == nil)
        {
            prefs.setValue("", forKey: Constants.watsonTTSSettingKeys.password)
        }
        
        // Watson IOT
        if (prefs.value(forKey: Constants.mqttConfigSettingKeys.orgId) == nil)
        {
            prefs.setValue("", forKey: Constants.mqttConfigSettingKeys.orgId)
        }
        if (prefs.value(forKey: Constants.mqttConfigSettingKeys.deviceType) == nil)
        {
            prefs.setValue("", forKey: Constants.mqttConfigSettingKeys.deviceType)
        }
        if (prefs.value(forKey: Constants.mqttConfigSettingKeys.deviceId) == nil)
        {
            prefs.setValue("", forKey: Constants.mqttConfigSettingKeys.deviceId)
        }
        if (prefs.value(forKey: Constants.mqttConfigSettingKeys.password) == nil)
        {
            prefs.setValue("", forKey: Constants.mqttConfigSettingKeys.password)
        }
        
        
        // Theme
        if (prefs.value(forKey: Constants.themeSettingKeys.hexColorCode) == nil)
        {
            prefs.setValue(Constants.colors.defaultTheme, forKey: Constants.themeSettingKeys.hexColorCode)
        }
        if (prefs.value(forKey: Constants.themeSettingKeys.title) == nil)
        {
            prefs.setValue(Constants.theme.defaultTitle, forKey: Constants.themeSettingKeys.title)
        }
        
        // About
        SettingsUtils.putVersionAndBuildnumInSettings()
    }

}
