var express = require('express');
var app = express();
var router = express.Router();
var watson = require( 'watson-developer-cloud' );
var location = require('../app/location/location');
var vcapServices = require('vcap_services');
var request = require('request');
var cfenv = require('cfenv');
var getWeather =  function(lat, long, callback) {

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
    var url = 'https://'+weatherConfig.username+':'+weatherConfig.password+'@twcservice.mybluemix.net:'+weatherConfig.port+'/api/weather/v1/geocode/'+lat+'/'+long+'/forecast/daily/10day.json?units=m&language=en-US'
    request(url, function(error, response, body){
          if(error) console.log(error);
          wConditions = JSON.parse(response.body);
          callback(null, wConditions.forecasts[0].narrative);
            });
};
module.exports.getWeather = getWeather;