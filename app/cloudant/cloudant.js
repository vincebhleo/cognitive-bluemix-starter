var Cloudant = require('cloudant');
var extend = require('util')._extend;
var vcapServices = require('vcap_services');
var Q = require('q');
var config = extend({
    username: process.env.cloudant_username,
    password: process.env.cloudant_password
}, vcapServices.getCredentials('cloudantNoSQLDB'));

// Initialize the library with account credential.
var cloudant = Cloudant({
    account: config.username,
    password: config.password
});

function retrieveDocData(rawData){
    var returnData = null;
    if(rawData!= null && rawData.rows != null && rawData.rows[0] != null){
        returnData = rawData.rows[0].doc;
    } else {
        console.warn("Error occured during Doc retrival");
    }
    return returnData;
}

var obj = {
    retrieveData: function (dbname) {
        var db = cloudant.db.use(dbname);
        var deferred = Q.defer();
        db.list({ include_docs: true }, function (err, body) {
            if (!err) {
                deferred.resolve(body);
            } else {
                deferred.reject(err);
            }

        });
        return deferred.promise;
    },
    updateData: function (dbname, id, doc) {
        var db = cloudant.db.use(dbname);
        var deferred = Q.defer();
        db.insert(doc, function (err, body) {
            if (!err) {
                deferred.resolve(body);
            } else {
                deferred.reject(err);
            }

        });
        return deferred.promise;
    },
    insertData: function (dbname, doc) {
        var db = cloudant.db.use(dbname);
        var deferred = Q.defer();
        db.insert(doc, function (err, body) {
            if (!err) {
                deferred.resolve(body);
            } else {
                deferred.reject(err);
            }

        });
        return deferred.promise;
    },
    retrieveDataById: function (dbname, id) {
        console.log("Retrieving DOC for ID : " + id);
        var db = cloudant.db.use(dbname);
        var deferred = Q.defer();
        db.list({include_docs: true, key: id }, function (err, body) {
            if (!err) {
                var extractedDoc = retrieveDocData(body);
                deferred.resolve(extractedDoc);
            } else {
                deferred.reject(err);
            }

        });
        return deferred.promise;
    },
    //retiveDataByParameter function retrun all the documents for that parameter selector
    //before using this function you have to create index for type in database of cloudant
    retrieveDataByType: function(dbname, value){
      var db = cloudant.db.use(dbname);
      var deferred = Q.defer();
      db.find({"selector":{type:value}}, function (err, result) {
          if (!err) {
              var extractedDoc = result;
              deferred.resolve(extractedDoc);
          } else {
              deferred.reject(err);
          }
      });
      return deferred.promise;
    },

    /*
      retrive a docs from DB with pageNo and PageSize
    */
    retrieveDocsByPageNo : function(dbname, pageNo, pageSize){
      var db = cloudant.db.use(dbname);
      var retrievedData = null;
      var skipCount = (pageNo - 1) * pageSize;
      var deferred = Q.defer();
      db.list({ limit:pageSize , skip : skipCount, include_docs: true  }, function (err, body) {
        if (!err) {
            deferred.resolve(body);
        } else {
            deferred.reject(err);
        }
      });
      return deferred.promise;
    },

    /*
      finding a docs from DB with defined selector
    */
    retrieveDocsBySelector : function(dbname, selector){
      var db = cloudant.db.use(dbname);
      var deferred = Q.defer();
      db.find(selector, function (err, body) {
        if (!err) {
            console.log(body);
            deferred.resolve(body);
        } else {
            console.log(err);
            deferred.reject(err);
        }
      });
      return deferred.promise;

    }
};
module.exports = obj;
