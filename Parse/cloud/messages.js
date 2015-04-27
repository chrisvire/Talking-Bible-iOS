var Mandrill = require("mandrill");
Mandrill.initialize()

Parse.Cloud.define("sendMessage", function (request, response) {
	var Message = Parse.Object.extend("Message");

	var newMessage = new Message();
    newMessage.set("name", request.params.name);
    newMessage.set("email", request.params.email);
    newMessage.set("phoneNumber", request.params.phoneNumber);
    newMessage.set("message", request.params.message);
    newMessage.set("deviceInformation", request.params.deviceInformation);
});

Parse.Cloud.afterSave("Message", function (request) {
    Parse.Config.get({

        success: function (config) {
            var mandrillKey = config.get("mandrillKey");
            var supportEmail = config.get("supportEmail");


        },

        error: function (error) {
            console.error(error);
        }

    });
});