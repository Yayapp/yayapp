var fs = require('fs');
var layer = require('cloud/layer-module.js');

var layerProviderID = 'layer:///providers/325c1b08-305a-11e5-9444-7ceb2e015ed0';
var layerKeyID = 'layer:///keys/543e166c-306a-11e5-b8ad-f60e4d0122e7';
var privateKey = fs.readFileSync('cloud/keys/layer-key.js');
layer.initialize(layerProviderID, layerKeyID, privateKey);

Parse.Cloud.define("generateToken", function(request, response) {
    var userID = request.params.userID;
    var nonce = request.params.nonce;
    if (!userID) throw new Error('Missing userID parameter');
    if (!nonce) throw new Error('Missing nonce parameter');
        response.success(layer.layerIdentityToken(userID, nonce));
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
//Parse.Cloud.define("hello", function(request, response) {
//  response.success("Hello world!");
//});
