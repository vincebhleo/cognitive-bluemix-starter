//
//  ThemeManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 17/01/17.
//  Copyright © 2017 Persistent. All rights reserved.
//

import Foundation
import UIKit

private let themeManager = ThemeManager()

class ThemeManager: NSObject
{
    var colorCode:String!
    var title:String!
    var logo:UIImage!
    
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
        
        self.logo = self.logoImage()
    }
    
    // MARK : Save image to Documents directory
    func saveImageToDocumentDirectory(image: UIImage)
    {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(Constants.logoImageNames.logoPng)
        print(paths)
        let imageData = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func documentDirectoryPath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func logoImage() -> UIImage
    {
        let fileManager = FileManager.default
        var logoImage :UIImage? = nil
        let imagePAth = (self.documentDirectoryPath() as NSString).appendingPathComponent(Constants.logoImageNames.logoPng)
        if fileManager.fileExists(atPath: imagePAth){
            logoImage = UIImage(contentsOfFile: imagePAth)!
        }else{
            print("No Image")
            // Set default logo
            logoImage = UIImage(named:Constants.logoImageNames.logo)
        }
        
        return logoImage!
    }
}
