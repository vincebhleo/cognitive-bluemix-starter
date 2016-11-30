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

}
