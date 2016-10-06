//reference: https://console.ng.bluemix.net/docs/services/IoT/applications/libraries/nodejs.html
var Client = require("ibmiotf");
var extend = require('util')._extend;
var vcapServices = require('vcap_services');
var cloudant = require("../cloudant/cloudant");
var uuid = require('node-uuid');
var _uuid=uuid.v4();
//var dataPublisher = null;
var appClientConfig = extend({
    "org": process.env.iotp_org,
    "id": _uuid,
    "auth-key": process.env.iotp_auth_key,
    "auth-token": process.env.iotp_auth_token
}, vcapServices.getCredentials('iotf-service'));
//iotf-service
function consumeMQTT(deviceId, command) {
    var deviceIdIndex = command.indexOf(' ');
    var _deviceId = command.substr(0, deviceIdIndex);
    var commandString = command.substr(deviceIdIndex + 1);
    var commandNameIndex = commandString.indexOf(' ');
    var commandName = commandString.substr(0, commandNameIndex);
    var commandParam = commandString.substr(commandNameIndex + 1);
    var mqtt = global[deviceId] || {
        "deviceId": deviceId
    };
    var commander = require("./command/" + commandName);
    if (commander && commander.process) {
        // we can pass datapublisher into commander and start pushing necessary data for the UI
        commander.process(mqtt, commandParam);
        global[deviceId] = mqtt;
    }
    //console.log(mqtt);
    return mqtt;

}
var appClient = new Client.IotfApplication(appClientConfig);
var iotp = {
    initIoTp: function() {
        appClient.connect();
        appClient.on("connect", function() {
            console.log("IOT platform connected");
            appClient.subscribeToDeviceEvents("vehicle");
        });
        appClient.on("error", function(err) {
            console.log("Error : " + err);
        });
        appClient.on("deviceEvent", function(deviceType, deviceId, eventType, format, payload) {
//            console.log("Device Event from :: " + deviceType + " : " + deviceId + " of event " + eventType + " with payload : " + payload);
            if (deviceType === "vehicle") {
                var _payload = JSON.parse("" + payload);
                var _deviceId = deviceId;
                var _command = _payload.command;
                //  console.log(_payload);
                var mqtt = consumeMQTT(_deviceId, _command);
                var currentTime = new Date();
                mqtt.insertDate = currentTime;
                cloudant.insertData("dummy", mqtt).then(function(response) {
                    console.log("insert mqtt." + response);
                }).fail(function(err) {
                    console.log("insert failed." + err);
                });
            }
        });
    }
};

module.exports = iotp;
