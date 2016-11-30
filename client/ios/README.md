Natural Language Interface
======================================

The NLI iOS app uses Watson iOS SDK to connect to watson STT and TTS services. MQTT-Client-Framework is used to communicate with Node Red application which in turn is configured to communicate with conversation service.


## Adding Devices:
We need to register device to able able to send and receive events/commands to/from IOTF. Following are the steps to register a device and obtain credentials.

1.	Go to the Overview page of Bluemix App which has been configured with cognitive-iotf-service
![Overview](/client/ios/images/Overview.png?raw=true "Overview page of Bluemix app")

2.	Select cognitive-iotf-service

3.	Click on Launch dashboard under “Connect your devices” tab
![ConnectDevices](/client/ios/images/ConnectDevices.png?raw=true "Connect devices")

4.	Select Devices from left side menu             
![Overview](/client/ios/images/SelectDevicesMenu.png?raw=true "Select devices menu") 

5.	Click on “Add Device” in the top right corner of Devices page.
![AddDevice](/client/ios/images/AddDevice.png?raw=true "Add device") 

6.	Click on create device type
![CreateDevice](/client/ios/images/CreateDevice.png?raw=true "Create device") 

7.	Enter name and desciption

8.	Click Next, until you get a create button.

9.	Click on create.

10.	Once Device Type is created. We need to create Device Id.

11.	Choose Device type you created from drop down and click next.

12.	Enter a Device Id and click next
![EnterDeviceId](/client/ios/images/EnterDeviceId.png?raw=true "Enter device id") 

13.	Provide a token. This is optional. If you don’t give a token value of your choice, a token would be automatically generated.
![ProvideToken](/client/ios/images/ProvideToken.png?raw=true "Provide token") 

14.	Click next until you get an Add button.

15.	Click on Add.

16.	Device credentials will be displayed. Copy the credentials as the auto generated tokens are non-recoverable. If you misplace this token, you will need to re-register the device to generate a new authentication token.
![DeviceCredsDisplay](/client/ios/images/DeviceCredsDisplay.png?raw=true "Device credentials display")

## Configure Credentials in Settings:
1.	Go to Settings App on iPad
2.	Select Natural Language Interface App
3.	Set the credentials which we obtained after registering device under Watson IOT.
4.	Similarly set the credentials for Watson STT, TTS.

![AppSettings](/client/ios/images/AppSettings.png?raw=true "App Settings") 
 
## iOS App Utilities:
iOS app has the following Utilities which can be reused in any app:

1. MQTTManager : Handles sending events to and receiving commands from IOTF.
  Usage is as follows:
  * Add MQTTManager file to your project
  * Add following lines of code to viewDidLoad:
      * MQTTManager.sharedInstance.delegate = self
      * MQTTManager.sharedInstance.readMQTTConfig()
      * MQTTManager.sharedInstance.initMQTT()
  * Implement the mqttDelegate method commandReceived to handle what should be done on receiving a command.

2. SettingsUtils : Alllows user to configure/input  values using app settings page.
  Usage is as follows:
  * Add SettingsUtils file to your project.
  * Add Settings Bundle and set the values for WatsonSTT, WatsonTTS, MQTT credentials in Root.plist.
  * These values will automatically be configurable from the app settings page.
  * Refer following lines of code to read the settings:
      * let prefs = UserDefaults.standard
      * username = prefs.string(forKey: Constants.watsonSTTSettingKeys.username)

3.	WatsonSTTManager : Handles conversion of speech to text.
  Usage is as follows:
  * Add WatsonSTTManager file to your project
  * Add following lines of code to viewDidLoad:
      * WatsonSTTManager.sharedInstance.delegate = self
      * WatsonSTTManager.sharedInstance.readCustomSTT()
      * WatsonSTTManager.sharedInstance.readWatsonSTTCreds()
      * WatsonSTTManager.sharedInstance.initSpeechToText()
  * Implement the watsonSTTDelegate method sendTranscription to handle transcription/error received from Watson STT.

4.	WatsonTTSManager : Handles conversion of text to speech.
Usage is as follows:
  * Add WatsonTTSManager file to your project
  * Add following lines of code to viewDidLoad:
      * WatsonTTSManager.sharedInstance.delegate = self
      * WatsonTTSManager.sharedInstance.readWatsonTTSCreds()
      * WatsonTTSManager.sharedInstance.initTextToSpeech()
  * Implement the watsonTTSDelegate method playWavData to handle data received from Watson TTS.

5.	AudioPlayManager : Handles playing audio.
Usage is as follows:
  * Add AudioPlayManager, MediaUtils file to your project
  * Create an instance of AudioPlayManager and call playWaveData method.

6.	CommonUtilityManager : Contains functions which are commonly required by all apps.
Usage is as follows:
  * Add CommonUtilityManager file to your project
  * Refer following example which calls showAlert method:
      * CommonUtilityManager.showAlert(title: Constants.errorMessages.somethingWentWrong, message: "")

7.	LocationManager : Handles fetching location and updating location as and when it changes.
Usage is as follows:
  * Add LocationManager file to your project
  * Add the following line of code in viewDidLoad:
      * LocationManager.sharedInstance.startUpdatingLocation()

8.	BaseViewController : A Controller class which prevents textfield from being hidden under the keyboard, when keyboard is shown. This class automatically moves the textfield up when the keyboard is shown.
Usage is as follows:
  * Inherit from BaseViewController

## Info.plist Settings : 
Add the following settings to info.plist, when using above mentioned Utilities:

1.	To use Watson Services 
Add the following key-value pairs
![SecuritySettings](/client/ios/images/securitySettings.png?raw=true "Security settings")  

2.	To use Location Services
Add the key-value pair, where key is Privacy - Location When In Use Usage Description and value will be a string which indicates purpose to use location services.

3.	To use Microphone 
Add the key-value pair,  where key is Privacy - Microphone Usage Description and value will be a string which indicates the purpose to use microphone.

## Steps To Build The Project : 
1.	Install Xcode 8.1
2.	Clone the repo by opening terminal and change directory to where you want the directory to be made and entering the following command:
git clone https://github.com/vincebhleo/cognitive-bluemix-starter.git
or use GitHub Desktop
3.	Install Carthage by downloading and installing the latest .pkg file from here: https://github.com/Carthage/Carthage/releases
4.	Build dependent frameworks by using the following commands: Note, if you have used Xcode 7, then you might have to change the location of your command line tools. Go to Xcode Preferences > Locations > set Command Line Tools to Xcode 8.1
cd path_to_your_directory/cognitive-bluemix-starter/client/iOS/Natural\ Language\ Interface 
carthage bootstrap --platform iOS
5.	Open the Xcode project by double clicking on the file:
Natural Language Interface.xcodeproj
6.	Run the project by picking a device or simulator from the Main Window Toolbar's Scheme menu.
