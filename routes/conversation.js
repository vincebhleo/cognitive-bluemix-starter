'use strict';
var express = require('express');
var app = express();
var router = express.Router();
var watson = require( 'watson-developer-cloud' );
var weather = require('../app/weather/weather');
var location = require('../app/location/location');
var vcapServices = require('vcap_services');
var request = require('request');
var vcapServices = require('vcap_services');
var extend = require('util')._extend;

var context_var = {};

// Create the service wrapper
var conversationConfig = extend({
  url: 'https://gateway.watsonplatform.net/conversation/api',
  username: process.env.CONVERSATION_USERNAME || '<CONVERSATION_USERNAME>',
  password: process.env.CONVERSATION_PASSWORD || '<CONVERSATION_PASSWORD>',
  version_date: '2016-07-11',
  version: 'v1'
}, vcapServices.getCredentials('conversation'));

var conversation = watson.conversation(conversationConfig);

router.get( '/', function(req, res, next) {
  var querytext = req.query.text;
  var workspace = process.env.CONVERSATION_WORKSPACEID || '<CONVERSATION_WORKSPACEID>';
  if ( !workspace || workspace === '<CONVERSATION_WORKSPACEID>' ) {
    return res.json( {
      'output': {
        'text': 'The app has not been configured with a <b>CONVERSATION_WORKSPACEID</b> environment variable.'
      }
    } );
  }
  var payload = {
    workspace_id: workspace,
    context: {},
    input: {}
  };
  if ( req.body ) {
    payload.input = {text: querytext};
    payload.context = context_var;
    console.log('Context conver id = '+ context_var.conversation_id);
  }

  // Send the input to the conversation service
  conversation.message( payload, function(err, data) {
    if ( err ) {
      return res.status( err.code || 500 ).json( err );
    }

    updateMessage(payload, data, function(err, data) {
      console.log('replyxxx '+ data);
      return res.status( 200 ).json( data );
    });
  });
});

function updateMessage(input, response, callbackFunc) {
  console.log('inside updateMessage: '+(JSON.stringify(response, null, 4)));
  context_var = response.context;
  console.log(JSON.stringify(context_var, null, 4));
  var city = context_var.place;
  var reqDate  = context_var.date;
  var responseText = response.output.text;

  // API to return date
  var curPlace  = context_var.curPlace;
  if(curPlace !== undefined )
  {
    var currentDate;
    var lat;
    var long;
    var options = {
      method: 'GET',
      url: 'https://maps.googleapis.com/maps/api/geocode/json',
      qs:{
        address:curPlace,
        key: process.env.GOOGLE_API_KEY || '<GOOGLE_API_KEY>'
      },
      header:{}
    };
    request(options, function (error, response, body) {
      if (error) throw new Error(error);
      var b = JSON.parse(response.body);
      lat = (b.results[0].geometry.location.lat);
      long = (b.results[0].geometry.location.lng);
      lat = Number((lat).toFixed(2));
      long = Number((long).toFixed(2));
      var dateurl = 'http://api.geonames.org/timezoneJSON?lat='+lat+'&lng='+long+'&username=cognibot';
      request(dateurl, function(error, response, body){
        if(error) console.log(error);
        currentDate = JSON.parse(response.body);
        context_var.curPlace = undefined;
        callbackFunc(null, 'Current date and time is '+currentDate.time);
        return ;
      });
      return;
    });
    return;
  }

  if(city === undefined) {return callbackFunc(null, responseText)} ;
  if(city != undefined){
    console.log('Context var: City is  '+city);
    console.log('calling location api to get lat long of '+city);
    var weather;
    var lat;
    var long;
    var options = {
      method: 'GET',
      url: 'https://maps.googleapis.com/maps/api/geocode/json',
      qs:{
        address:city,
        key: process.env.GOOGLE_API_KEY || '<GOOGLE_API_KEY>'
      },
      header:{}
    };

  var wConditions;
  //calling google geocode api to get latitude, longitude of the city
  request(options, function (error, response, body) {
    if (error) throw new Error(error);
    var b = JSON.parse(response.body);
    lat = (b.results[0].geometry.location.lat);
    long = (b.results[0].geometry.location.lng);
    lat = Number((lat).toFixed(2));
    long = Number((long).toFixed(2));
    var no_day;

    //calling weather company data service from bluemix.
    var url = 'https://'+process.env.WEATHER_USERNAME+':'+process.env.WEATHER_PASSWORD+'@twcservice.mybluemix.net:443/api/weather/v1/geocode/'+lat+'/'+long+'/forecast/daily/10day.json?units=m&language=en-US'
    request(url, function(error, response, body){
      if(error) console.log(error);
        wConditions = JSON.parse(response.body);
        context_var.place = undefined;
        return callbackFunc(null, wConditions.forecasts[0].narrative);
      });
    });
  }
}

module.exports = router;
