//reference: https://console.ng.bluemix.net/docs/services/Weather/weather_tutorials_samples.html#current_conditions
var extend = require('util')._extend;
var vcapServices = require('vcap_services');
var Q = require('q');
var weatherConfig = extend({
    "host": "twcservice.mybluemix.net",
    "port": "443",
    "username":  process.env.weather_username ||'<USERNAME>',
    "password":  process.env.weather_username || '<PASSWORD>'
}, vcapServices.getCredentials('weatherinsights'));
//var client = new Client();

function prepareConfig(service, longitude, latitude, unit, language){
  var _longitude = longitude || 0;
  var _latitude = latitude || 0;
  var _unit = unit || "m";
  var _language = language || "en-US";
  // var url="https://" + weatherConfig.username + ":" + weatherConfig.password + "@" + weatherConfig.host + ":" + weatherConfig.port + "/api/weather/v1/geocode/" + _latitude + "/" + _longitude + "/observations.json?units=" + _unit + "&language=" + _language;
  // console.log(url);
  // return client.get(url);
  var _service = service || "/api/weather/v2/observations/current";
  var url = "https://" + weatherConfig.host + _service;
  var config = {
      url: url,
      auth: {
          username: weatherConfig.username,
          password: weatherConfig.password
      },
      qs: {
          geocode: [_latitude, _longitude].join(','),
          units: _unit,
          language: _language
      }
  };
  return config;
}

var obj = {
    getCurrentCondition: function(longitude, latitude, unit, language) {

        var service = "/api/weather/v2/observations/current";
        var config = prepareConfig(service, longitude, latitude, unit, language);
        console.log(config);
        var request = require('request');
        var deferred = new Q.defer();
        request(config, function(error, response, body) {
            if (!error && response.statusCode == 200) {
                var result = JSON.parse(body);
                console.log("S");
                console.log(body);
                deferred.resolve(result);

            } else {
                console.log("Error");
                console.log(error);
                console.log(body);
                deferred.reject(error);
            }
        });

        return deferred.promise;
    },
    //Function returns the forecast for specified day. Limit is next 10 days only.
    //It will return a weather forecast for ahead of {X = nextDayNo} day.
    getComingXDayCondition : function(nextDayNo, longitude, latitude, unit, language) {
        //console.log("tomorrows function");
        var _nextDayNo = nextDayNo || 1;
        if(_nextDayNo < 0){
          _nextDayNo = 0;
        }
        else if(_nextDayNo > 10){
          _nextDayNo = 10;
        }
        var service = "/api/weather/v2/forecast/daily/10day";
        var config = prepareConfig(service, longitude, latitude, unit, language);
        var request = require('request');
        var deferred = new Q.defer();
        request(config, function(error, response, body) {
            if (!error && response.statusCode == 200) {
                var result = JSON.parse(body);
                var response = {};
                response.metadata = result.metadata;
                response.weather = result.forecasts[_nextDayNo];
                //response will contain only metadata and tomorrows temperatue
                deferred.resolve(response);

            } else {
                deferred.reject(error);
            }
        });

        return deferred.promise;
    },
    //Function returns the forecast for specified hour no. Limit is next 24 hrs only
    //It will return a weather forecast for ahead of {X = nextHourNo} hour.
    getNextXHourCondition : function(nextHourNo, longitude, latitude, unit, language) {
        //console.log("NextHourCondition function");
        var _nextHourNo = nextHourNo || 1;
        if(_nextHourNo < 0){
          _nextHourNo = 1;
        }
        else if(_nextHourNo > 24){
          _nextHourNo = 24;
        }
        var service = "/api/weather/v2/forecast/hourly/24hour";
        var config = prepareConfig(service, longitude, latitude, unit, language);
        var request = require('request');
        var deferred = new Q.defer();
        request(config, function(error, response, body) {
            if (!error && response.statusCode == 200) {
                var result = JSON.parse(body);
                var response = {};
                response.metadata = result.metadata;
                response.weather = result.forecasts[_nextHourNo-1];
                deferred.resolve(response);

            } else {
                deferred.reject(error);
            }
        });

        return deferred.promise;
    }

}
module.exports = obj;
