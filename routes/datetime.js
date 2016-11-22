var request = require('request');
var getDateTime =  function(lat, long, callback) {
	
	   var dateurl = 'http://api.geonames.org/timezoneJSON?lat='+lat+'&lng='+long+'&username=cognibot';
    request(dateurl, function(error, response, body){
          if(error) console.log(error);
          console.log('calling service');
          console.log(response.body);
          var currentDate = JSON.parse(response.body);
          callback(null,'Current date and time is '+currentDate.time);
            });
};
module.exports.getDateTime = getDateTime;
