//
// Articles push notifications
//

Parse.Cloud.afterSave("Article", function (request) {
	pushArticleUpdate();
});

Parse.Cloud.afterDelete("Article", function (request) {
	pushArticleUpdate();
});

function pushArticleUpdate() {
	Parse.Push.send({
	  	channels: [ "CoreDataUpdates" ],
	  	data: {
	  		"channel": "ArticleUpdates",
	     	"content-available": "1"
	  	}
	}, { 
		success: function() { 
	  		console.log("Sent push notification to ArticleUpdates");
		}, 

		error: function(error) { 
	    	console.error(error);
	  	}
	});
}