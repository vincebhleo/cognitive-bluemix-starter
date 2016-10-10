var express = require('express');
var router = express.Router();
var request = require('request');
var extend = require('util')._extend;
var vcapServices = require('vcap_services');
var Q = require('q');
var fs = require('fs');

var weatherConfig = extend({
    "host": "twcservice.mybluemix.net",
    "port": "443",
    "username": process.env.weather_username || '7e01945d-4208-4612-989c-1133c05dc0ef',
    "password": process.env.weather_password || 'yigKrek3Su'
}, vcapServices.getCredentials('Weather Company Data-db'));
//var client = new Client();

function prepareConfig(service){
  // var url="https://" + weatherConfig.username + ":" + weatherConfig.password + "@" + weatherConfig.host + ":" + weatherConfig.port + "/api/weather/v1/geocode/" + _latitude + "/" + _longitude + "/observations.json?units=" + _unit + "&language=" + _language;
  // console.log(url);
  // return client.get(url);
  var _service = service ;
  var url = "https://" + weatherConfig.host + _service;
  var config = {
      url: url,
      auth: {
          username: weatherConfig.username,
          password: weatherConfig.password
      }
  };
  return config;
}

const weather_host = 'https://7e01945d-4208-4612-989c-1133c05dc0ef:yigKrek3Su@twcservice.mybluemix.net';

function location(path, done) {
    var url = weather_host + path;
    //console.log(url, qs);
    request({
        url: url,
        method: "GET",
        headers: {
            "Content-Type": "application/json;charset=utf-8",
            "Accept": "application/json"
        }
    }, function(err, req, data) {
        if (err) {
            done(err);
        } else {
            if (req.statusCode >= 200 && req.statusCode < 400) {
                try {
                    done(null, JSON.parse(data));
                } catch(e) {
                    console.log(e);
                    done(e);
                }
            } else {
                console.log(err);
                done({ message: req.statusCode, data: data });
            }
        }
    });
}
var obj = {
    getLatLong: function(city) {

        var service = '/api/weather/v3/location/search?query='+city+'&locationType=city&countryCode=US&adminDistrictCode=GA&language=en-US';
        var config = prepareConfig(service);
        console.log(config);
        var request = require('request');
        var deferred = new Q.defer();
        request(config, function(error, response, body) {
            if (!error && response.statusCode == 200) {
                var result = JSON.parse(body);
                deferred.resolve(result);

            } else {
                deferred.reject(error);
            }
        });

        return deferred.promise;
    }
};
module.exports = obj;
