//
//  CommonUtilityManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 14/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import UIKit

class CommonUtilityManager: NSObject {
    
    class func showAlert(title: String, message : String) -> UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil))
        
        return alert
    }
    
    class func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        
        //let scale = newWidth / image.size.width
        //let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        image.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
