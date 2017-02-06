//
//  SettingsViewController.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 20/01/17.
//  Copyright © 2017 Persistent. All rights reserved.
//

import UIKit

protocol settingsDelegate {
    func didFinishSaving()
}

class SettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var table: UITableView!
    // Watson STT
    @IBOutlet weak var watsonSTTUsernameTextField: UITextField!
    @IBOutlet weak var watsonSTTPasswordTextField: UITextField!
    @IBOutlet weak var watsonSTTCustomSwitch: UISwitch!
    @IBOutlet weak var watsonSTTCustomizationIdTextField: UITextField!
    
    // Watson TTS
    @IBOutlet weak var watsonTTSUsernameTextField: UITextField!
    @IBOutlet weak var watsonTTSPasswordTextField: UITextField!
    
    // Watson IOT
    @IBOutlet weak var orgIdTextField: UITextField!
    @IBOutlet weak var deviceTypeTextField: UITextField!
    @IBOutlet weak var deviceIdTextField: UITextField!
    @IBOutlet weak var watsonIOTPasswordTextField: UITextField!
    
    // Theme
    @IBOutlet weak var hexColorCodeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var logoImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var logoImage: UIImage?
    
    // About
    @IBOutlet weak var versionTextField: UITextField!
    @IBOutlet weak var buildNoTextField: UITextField!
    
    var delegate:settingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            // do some task
            self.loadSettings()
        }
        
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func save() {
        
        let prefs = UserDefaults.standard
        
        // Watson STT
        prefs.setValue(self.watsonSTTUsernameTextField.text, forKey: Constants.watsonSTTSettingKeys.username)
        prefs.setValue(self.watsonSTTPasswordTextField.text, forKey: Constants.watsonSTTSettingKeys.password)
        prefs.set(self.watsonSTTCustomSwitch.isOn, forKey: Constants.watsonSTTSettingKeys.customSttPreference)
        prefs.setValue(self.watsonSTTCustomizationIdTextField.text, forKey: Constants.watsonSTTSettingKeys.customizationId)
        
        // Watson TTS
        prefs.setValue(self.watsonTTSUsernameTextField.text, forKey: Constants.watsonTTSSettingKeys.username)
        prefs.setValue(self.watsonTTSPasswordTextField.text, forKey: Constants.watsonTTSSettingKeys.password)
        
        // Watson IOT
        prefs.setValue(self.orgIdTextField.text, forKey: Constants.mqttConfigSettingKeys.orgId)
        prefs.setValue(self.deviceTypeTextField.text, forKey: Constants.mqttConfigSettingKeys.deviceType)
        prefs.setValue(self.deviceIdTextField.text, forKey: Constants.mqttConfigSettingKeys.deviceId)
        prefs.setValue(self.watsonIOTPasswordTextField.text, forKey: Constants.mqttConfigSettingKeys.password)
        
        // Theme
        prefs.setValue(self.hexColorCodeTextField.text, forKey: Constants.themeSettingKeys.hexColorCode)
        prefs.setValue(self.titleTextField.text, forKey: Constants.themeSettingKeys.title)
        if(self.logoImage != nil)
        {
            ThemeManager.sharedInstance.saveImageToDocumentDirectory(image: self.logoImage!)
        }
        
        let alert:UIAlertController = CommonUtilityManager.showAlert(title: Constants.messages.settingsSaved, message: "")
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.present(alert, animated: true, completion: nil)
            self.delegate?.didFinishSaving()
        }
    }
    
    func loadSettings()
    {
        let prefs = UserDefaults.standard
        
        // Watson STT
        if let watsonSTTUsername = prefs.string(forKey: Constants.watsonSTTSettingKeys.username)
        {
            DispatchQueue.main.async{
                self.watsonSTTUsernameTextField.text = watsonSTTUsername
            }
        }
        if let watsonSTTPassword = prefs.string(forKey: Constants.watsonSTTSettingKeys.password)
        {
            DispatchQueue.main.async{
                self.watsonSTTPasswordTextField.text = watsonSTTPassword
            }
        }
        
        let watsonSTTCustomPreference = prefs.bool(forKey: Constants.watsonSTTSettingKeys.customSttPreference)
        DispatchQueue.main.async{
            self.watsonSTTCustomSwitch.setOn(watsonSTTCustomPreference, animated: false)
        }
        
        if let watsonSTTCustomizationId = prefs.string(forKey: Constants.watsonSTTSettingKeys.customizationId)
        {
            DispatchQueue.main.async{
                self.watsonSTTCustomizationIdTextField.text = watsonSTTCustomizationId
            }
        }
        
        
        // Watson TTS
        if let watsonTTSUsername = prefs.string(forKey: Constants.watsonTTSSettingKeys.username)
        {
            DispatchQueue.main.async{
                self.watsonTTSUsernameTextField.text = watsonTTSUsername
            }
        }
        if let watsonTTSPassword = prefs.string(forKey: Constants.watsonTTSSettingKeys.password)
        {
            DispatchQueue.main.async{
                self.watsonTTSPasswordTextField.text = watsonTTSPassword
            }
        }
        
        // Watson IOT
        if let orgId = prefs.string(forKey: Constants.mqttConfigSettingKeys.orgId)
        {
            DispatchQueue.main.async{
                self.orgIdTextField.text = orgId
            }
        }
        if let deviceType = prefs.string(forKey: Constants.mqttConfigSettingKeys.deviceType)
        {
            DispatchQueue.main.async{
                self.deviceTypeTextField.text = deviceType
            }
        }
        if let deviceId = prefs.string(forKey: Constants.mqttConfigSettingKeys.deviceId)
        {
            DispatchQueue.main.async{
                self.deviceIdTextField.text = deviceId
            }
        }
        if let watsonIOTPassword = prefs.string(forKey: Constants.mqttConfigSettingKeys.password)
        {
            DispatchQueue.main.async{
                self.watsonIOTPasswordTextField.text = watsonIOTPassword
            }
        }
        
        // Theme
        if let hexColorCode = prefs.string(forKey: Constants.themeSettingKeys.hexColorCode)
        {
            DispatchQueue.main.async{
                self.hexColorCodeTextField.text = hexColorCode
            }
        }
        if let title = prefs.string(forKey: Constants.themeSettingKeys.title)
        {
            DispatchQueue.main.async{
                self.titleTextField.text = title
            }
        }
        let logoImage = ThemeManager.sharedInstance.logoImage()
        DispatchQueue.main.async{
            self.logoImageView.image = logoImage
        }

        
        // About
        if let buildNo = prefs.string(forKey: Constants.buildSettingKeys.buildNo)
        {
            DispatchQueue.main.async{
                self.buildNoTextField.text = buildNo
            }
        }
        if let version = prefs.string(forKey: Constants.buildSettingKeys.version)
        {
            DispatchQueue.main.async{
                self.versionTextField.text = version
            }
        }
    }
    
    @IBAction func selectLogoImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // resize image
            var width:CGFloat
            var height:CGFloat
            if(UIDevice.current.userInterfaceIdiom == .phone)
            {
                // iPhone
                width = Constants.logoImageSize.iPhoneWidth
                height = Constants.logoImageSize.iPhoneHeight
            }
            else
            {
                // iPad
                width = Constants.logoImageSize.iPadWidth
                height = Constants.logoImageSize.iPhoneHeight
            }
            let resizedImage = CommonUtilityManager.resizeImage(image: pickedImage, newWidth: width, newHeight: height)
            logoImageView.image = resizedImage
            logoImage = resizedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=self.table.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }

}
