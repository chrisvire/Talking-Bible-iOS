//
// CoreDataArchives push notifications
//

if (typeof String.prototype.endsWith !== 'function') {
    String.prototype.endsWith = function(suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };
}

Parse.Cloud.afterSave("CoreDataArchive", function (request) {
	
	Parse.Config.get({

		success: function (config) {
			var cloudfrontURL = config.get("cloudfrontURL");
			var file = request.object.get("file");

			if (file == undefined || cloudfrontURL == undefined) {
				return;
			}

			if (!file.endsWith(".zip")) {
				console.warn("Did not send push notification to CoreDataUpdates for " + file);
				return;
			}

			var url = cloudfrontURL + file;

			Parse.Push.send({
			  	channels: [ "CoreDataUpdates" ],
			  	data: {
			  		"channel": "CoreDataUpdates",
			  		"dbArchive": url,
			     	"content-available": "1"
			  	}
			}, { 
				success: function() { 
			  		console.log("Sent push notification to CoreDataUpdates for " + url);
				}, 

				error: function(error) { 
			    	console.error(error);
			  	}
			});
		},

		error: function (error) {
			console.error(error);
		}

	})
});

