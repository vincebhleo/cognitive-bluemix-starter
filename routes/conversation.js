'use strict';
var express = require('express');
var app = express();
var router = express.Router();
var watson = require( 'watson-developer-cloud' );
var location = require('../app/location/location');
var vcapServices = require('vcap_services');
var request = require('request');
var cfenv = require('cfenv');
var datetime = require('datetime');
var context_var = {};
// Create the service wrapper
var conversation = watson.conversation( {
  url: 'https://gateway.watsonplatform.net/conversation/api',
  username: process.env.conversation_username || '<USERNAME>',
  password: process.env.convesation_password || '<PASSWORD>',
  version_date: '2016-07-11',
  version: 'v1'
}, vcapServices.getCredentials('conversation'));
// load local VCAP configuration
var vcapLocal = null;
try {
  vcapLocal = require("./vcap-local.json");
  console.log("Loaded local VCAP", vcapLocal);
} catch (e) {
  console.error(e);
}
// get the app environment from Cloud Foundry, defaulting to local VCAP
var appEnvOpts = vcapLocal ? {
  vcap: vcapLocal
} : {};
var appEnv = cfenv.getAppEnv(appEnvOpts);
var weatherConfig = appEnv.getServiceCreds("cognitive-weatherinsights");
var wConditions;
var b;
var currentDate;
var lat;
var long;
var options;

router.post( '/', function(req, res, next) {
	
  var qryParams = req.body.text;
  lat = req.body.lat;
  long = req.body.long;
  console.log('input text--------------------------->>>>>');
  console.log(req.body.text);
  var workspace = '0f120182-c05f-4b1a-b901-72ab52a95c9a';
  	var err ;
  if ( !workspace ) {
  	err = {
      'output': {
        'text': 'The app has not been configured with a <b>WORKSPACE_ID</b> environment variable. Please refer to the ' +
        '<a href="https://github.com/watson-developer-cloud/conversation-simple">README</a> documentation on how to set this variable. <br>' +
        'Once a workspace has been defined the intents may be imported from ' +
        '<a href="https://github.com/watson-developer-cloud/conversation-simple/blob/master/training/car_workspace.json">here</a> in order to get a working application.'
      }
  };
      return res.status(500).json(err);   
  }
var payload = {
    workspace_id: workspace,
    context: {}
};
payload.input = {text: qryParams};
if ( req.body ) {
	 	payload.input ={text: qryParams};
      payload.context = context_var;
	}
  // Send the input to the conversation service
conversation.message( payload, function(err, data) {
    if ( err ) {
      return res.status( err.code || 500 ).json( err );
    }
updateMessage(payload, data, function(err, data) {
      return res.status( 200 ).json( data );
    });
  });
});

function getLatLong(curPlace)
{
  options = {
   method: 'GET',
   url: 'https://maps.googleapis.com/maps/api/geocode/json',
   qs:{
     address:curPlace,
     key: 'AIzaSyBCkRI_Emw5Zc73676jS2K8ZUakThPaS2w'
   },
   header:{}
 };
 
request(options, function (error, response, body) {
           if (error) throw new Error(error);
           b = JSON.parse(response.body);
           lat = (b.results[0].geometry.location.lat);
           long = (b.results[0].geometry.location.lng);
           lat = Number((lat).toFixed(2));
           long = Number((long).toFixed(2));
           });
           return [lat,long];
}

function updateMessage(input, response, callbackFunc) {
  context_var = response.context;
  var city = context_var.place;
  var responseText = response.output.text;
  var curPlace  = context_var.curPlace;
if(response.intents[0].intent ==='date')
{
	datetime.getCurrentDateTime();
    //var arr = getLatLong(curPlace);
    var dateurl = 'http://api.geonames.org/timezoneJSON?lat='+lat+'&lng='+long+'&username=cognibot';
    request(dateurl, function(error, response, body){
          if(error) console.log(error);
          console.log('calling service');
          console.log(response.body);
          currentDate = JSON.parse(response.body);
          context_var.curPlace = undefined;
          callbackFunc(null, 'Current date and time is '+currentDate.time);
              
              return ;
            });
        return;
}
if(response.intents[0].intent ==='weather')
{
       // var arr = getLatLong(city);
        var url = 'https://'+weatherConfig.username+':'+weatherConfig.password+'@twcservice.mybluemix.net:'+weatherConfig.port+'/api/weather/v1/geocode/'+lat+'/'+long+'/forecast/daily/10day.json?units=m&language=en-US'
        request(url, function(error, response, body){
          if(error) console.log(error);
          wConditions = JSON.parse(response.body);
          //responseText = wConditions.forecasts[0].narrative;
          context_var.place = undefined;
          console.log(wConditions.forecasts[0].narrative);
          return callbackFunc(null, wConditions.forecasts[0].narrative);
        });
}
}
module.exports = router;
