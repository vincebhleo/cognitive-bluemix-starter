//
//  MainViewController.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 11/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import MQTTFramework
import UIKit

class MainViewController: BaseViewController, watsonSTTDelegate, watsonTTSDelegate, mqttDelegate, UITextFieldDelegate{

    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var conversationScrollView: UIScrollView!
    var audioPlayManager: AudioPlayManager = AudioPlayManager()
    @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
    
    var lastChatBubbleY: CGFloat = Constants.chatBubbleDimensions.lastChatBubbleY
    var internalPadding: CGFloat = Constants.chatBubbleDimensions.internalPadding
    var lastMessageType: BubbleDataType?
        
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        LocationManager.sharedInstance.startUpdatingLocation()
        self.longPressGesture.minimumPressDuration = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MQTTManager.sharedInstance.delegate = self
        MQTTManager.sharedInstance.readMQTTConfig()
        MQTTManager.sharedInstance.initMQTT()
        
        WatsonSTTManager.sharedInstance.delegate = self
        WatsonSTTManager.sharedInstance.readWatsonSTTCreds()
        WatsonSTTManager.sharedInstance.readCustomSTT()
        WatsonSTTManager.sharedInstance.initSpeechToText()
        
        WatsonTTSManager.sharedInstance.delegate = self
        WatsonTTSManager.sharedInstance.readWatsonTTSCreds()
        WatsonTTSManager.sharedInstance.initTextToSpeech()
        
        ThemeManager.sharedInstance.readThemeSettings()
        self.setThemeColor()
        self.setTitle()
        self.setLogo()
        
        self.isConfigSet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        //reset vars
        WatsonSTTManager.sharedInstance.isTranscriptionSent = false
        
        if sender.state == .began {
            print("long tap began")
            DispatchQueue.main.async {
                self.speakerButton.setImage(UIImage(named:Constants.speakerIconImageNames.speakerIconHighlighted), for: UIControlState.normal)
            }
            WatsonSTTManager.sharedInstance.startMicrophone()
            audioPlayManager.playFile(fileName: "listening_sound", type: "mp3")
        }
        else if sender.state == .ended {
            print("long tap ended")
            DispatchQueue.main.async {
                self.speakerButton.setImage(UIImage(named:Constants.speakerIconImageNames.speakerIcon), for: UIControlState.normal)
            }
            WatsonSTTManager.sharedInstance.stopMicrophone()
        }
    }
    
    // MARK: - watsonSTTDelegate methods
    func sendTranscription(transcription: String?, error:String?)
    {
        if(error != nil)
        {
            print("Watson STT error")
            WatsonTTSManager.sharedInstance.convertTextToSpeech(text: error!)
        }
        else if(transcription != nil)
        {
            print("Watson STT text ",transcription!)
            guard (transcription?.characters.count)! > 0 else {
                sendTranscription(transcription: nil,error: Constants.errorMessages.somethingWentWrong)
                return
            }
            
            let chatBubbleData1 = ChatBubbleData(text: transcription, image:nil, date: NSDate(), type: .Mine)
            addChatBubble(data: chatBubbleData1)
            let message:Data = MQTTManager.sharedInstance.createTextMessage(text: transcription!)
            MQTTManager.sharedInstance.publish(topic: Constants.mqttJsonKeys.publishTopic, message: message)

        }
    }
    
    // MARK: - watsonTTSDelegate methods
    func playWavData(data: NSData?, error:String?)
    {
        if(error != nil)
        {
            print("Watson TTS error")
            let alert:UIAlertController = CommonUtilityManager.showAlert(title: Constants.errorMessages.somethingWentWrong, message: "")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        else if(data != nil)
        {
            audioPlayManager.playWaveData(data: data!)
        }
    }
    
    // MARK: - mqttDelegate methods
    func commandReceived(message:String)
    {
        WatsonTTSManager.sharedInstance.convertTextToSpeech(text: message)
        if(message != "")
        {
            let chatBubbleData2 = ChatBubbleData(text: message, image:nil, date: NSDate(), type: .Opponent)
            addChatBubble(data: chatBubbleData2)
        }
    }
    
    // MARK: - configuration incomplete in Settings App
    func isConfigSet()
    {
        var message:String = ""
        if(WatsonSTTManager.sharedInstance.isWatsonSTTConfigIncomplete)
        {
            message += Constants.errorMessages.watsonSTTConfigIncomplete
        }
        if(WatsonSTTManager.sharedInstance.isWatsonSTTCustomConfigIncomplete)
        {
            message += Constants.errorMessages.watsonSTTCustomConfigIncomplete
        }
        if(WatsonTTSManager.sharedInstance.isWatsonTTSConfigIncomplete)
        {
            if(message != "")
            {
                message += Constants.errorMessages.mesgSeperatorComma
            }
            message += Constants.errorMessages.watsonTTSConfigIncomplete
        }
        if(MQTTManager.sharedInstance.isMQTTConfigIncomplete)
        {
            if(message != "")
            {
                message += Constants.errorMessages.mesgSeperatorAnd
            }
            message += Constants.errorMessages.mqttConfigIncomplete
        }
        
        if(message != "")
        {
            let alert:UIAlertController = CommonUtilityManager.showAlert(title: "\(Constants.errorMessages.configIncomplete)\(message)", message: "")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        DispatchQueue.main.async {
            textField.resignFirstResponder() // Dismiss the keyboard
            
            //reset vars
            WatsonSTTManager.sharedInstance.isTranscriptionSent = false
            
            // Execute additional code
            self.sendTranscription(transcription: textField.text, error: nil)
            textField.text = ""
        }
        return true
    }
    
    // MARK: - Chat Bubble methods
    func addChatBubble(data: ChatBubbleData) {
        DispatchQueue.main.async {
            let padding:CGFloat = self.lastMessageType == data.type ? self.internalPadding/3.0 :  self.internalPadding
            let chatBubble = ChatBubble(data: data, startY:self.lastChatBubbleY + padding)
            self.conversationScrollView.addSubview(chatBubble)
            
            self.lastChatBubbleY = chatBubble.frame.maxY
            
            
            self.conversationScrollView.contentSize = CGSize(width:self.conversationScrollView.frame.width, height:self.lastChatBubbleY + self.internalPadding)
        }
        self.moveToLastMessage()
        lastMessageType = data.type
    }
    
    func moveToLastMessage() {
        DispatchQueue.main.async {
            if self.conversationScrollView.contentSize.height > self.conversationScrollView.frame.height {
                let contentOffSet = CGPoint(x:0.0, y:self.conversationScrollView.contentSize.height - self.conversationScrollView.frame.height)
                self.conversationScrollView.setContentOffset(contentOffSet, animated: true)
            }
        }
    }
    
    // MARK: - Theme methods
    func setThemeColor()
    {
        print(ThemeManager.sharedInstance.colorCode)
        let color:UIColor = UIColor(hexString: ThemeManager.sharedInstance.colorCode)
        self.headerView.backgroundColor = color
        self.logoView.backgroundColor = color
        self.titleView.backgroundColor = color
        self.speakerButton.backgroundColor = color
    }
    
    func setTitle()
    {
        self.titleLabel.text = ThemeManager.sharedInstance.title
    }
    
    func setLogo()
    {
        self.logoImageView.image = ThemeManager.sharedInstance.logo
    }
}
