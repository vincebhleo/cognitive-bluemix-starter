//
//  ThemeManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 17/01/17.
//  Copyright © 2017 Persistent. All rights reserved.
//

import Foundation


private let themeManager = ThemeManager()

class ThemeManager: NSObject
{
    var colorCode:String!
    var title:String!
    
    class var sharedInstance: ThemeManager {
        return themeManager
    }
    
    func readThemeSettings()
    {
        let prefs = UserDefaults.standard
        self.colorCode = prefs.string(forKey: Constants.themeSettingKeys.hexColorCode)
        
        if(self.colorCode.isEmpty)
        {
            self.colorCode = Constants.colors.defaultTheme
        }
        
        if(!self.colorCode.contains("#"))
        {
            self.colorCode = "#"+self.colorCode
        }
        
        self.title = prefs.string(forKey: Constants.themeSettingKeys.title)
        if(self.title.isEmpty)
        {
            self.title = Constants.theme.defaultTitle
        }
    }
}
