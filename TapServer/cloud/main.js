
// Use Parse.Cloud.define to define as many cloud functions as you want.

Parse.Cloud.define("getCurrentDate", function(request, response) {
	var now = new Date();
	var year = "" + now.getFullYear();
	var month = "" + (now.getMonth() + 1); if (month.length == 1) { month = "0" + month; }
	var day = "" + now.getDate(); if (day.length == 1) { day = "0" + day; }
	var hour = "" + now.getHours(); if (hour.length == 1) { hour = "0" + hour; }
	var minute = "" + now.getMinutes(); if (minute.length == 1) { minute = "0" + minute; }
	var second = "" + now.getSeconds(); if (second.length == 1) { second = "0" + second; }

	response.success("" + year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second);
});

Parse.Cloud.job("chooseWinner", function(request, response) {
	var now = new Date();
	var dayOfWeek = now.getDay();

	if (dayOfWeek == 1) {
		Parse.Cloud.useMasterKey();

		var objectToSave = [];
		var tapInfo = Parse.Object.extend("TapInfo");
		var query = new Parse.Query(tapInfo);

		query.descending("entries");
		query.find().then(function(results) {
			// Do something with the returned Parse.Object values
			for (var i = 0; i < results.length; i++) {
				if (i == 0) {
					results[i].set("isWinner", true);
					results[i].set("taps", 0);
					results[i].set("entries", 0);

					var earned = results[i].get("earnedMoney");
					var wins = results[i].get("wins");
					var winDate = (new Date()).getTime();

					earned += 100;
					wins += 1;

					results[i].set("earnedMoney", earned);
					results[i].set("wins", wins);
					results[i].set("winDate", winDate);

					objectToSave.push(results[i]);					
				} else {
					results[i].set("isWinner", false);
					results[i].set("taps", 0);
					results[i].set("entries", 0);

					objectToSave.push(results[i]);	
				}
			}
		}).then(function() {
			Parse.Object.saveAll(objectToSave, {
				success: function(list) {
					// All the objects were saved.
					if (response) {
						response.success("Update completed successfully.");
					}
				}, error: function(model, error) {
					// An error occurred while saving one of the objects.
					if (response) {
						response.error(error);
					}
				}
			});
		}, function(error) {
			response.error("Error: " + error.code + " " + error.message);		
		});	
	} else {
		response.error("No execution Time!");
	}	
});

Parse.Cloud.job("resetWinner", function(request, response) {
	var now = new Date();
	var dayOfWeek = now.getDay();

	if (dayOfWeek == 1) {
		Parse.Cloud.useMasterKey();

		var TapInfo = Parse.Object.extend("TapInfo");
		var query = new Parse.Query(TapInfo);

		query.equalTo("isWinner", true);
		query.find({
	  		success: function(results) {    		
			    // Do something with the returned Parse.Object values		    
			    results[0].set("isWinner", false);
			    results[0].save();		

			    response.success("Success!");      	
			},
	  		error: function(error) {
	    		response.error("Error: " + error.code + " " + error.message);
		  	}
		});
	} else {
		response.error("No execution Time!");
	}	  	
});




