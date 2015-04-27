//
// Make a Stripe donation
//

var Stripe = require('stripe');

// Replace this with your Stripe secret key, found at https://dashboard.stripe.com/account/apikeys
var stripe_secret_key = "sk_test_jDB1vV2srPZQDvHO6MRKKvRn";

Stripe.initialize(stripe_secret_key);

Parse.Cloud.define("charge", function(request, response) {
    var query = new Parse.Query("Donor");
    query.equalTo("email", request.params.email);
    query.first({
        success: function (object) {
            if (object !== undefined) {
                foundExistingParseDonor(request, response, object);
            } else {
                didNotFindExistingParseDonor(request, response);
            }
        },
        error: function (object, error) {
            response.error(error);
        },
        useMasterKey: true
    });
});

function foundExistingParseDonor(request, response, object) {
    Stripe.Customers.update(object.get("stripeCustomerId"), {
        description: request.params.fullName,
        card: request.params.token,
        metadata: {
            name: request.params.fullName,
            phone: request.params.phone
        }
    }, {
        success: function (httpResponse) {
            stripeCreatedOrUpdatedCustomer(request, response, httpResponse);
        },
        error: function (httpResponse) {
            response.error("Uh oh, something went wrong.");
        }
    });
}

// Update existing Stripe customer
function didNotFindExistingParseDonor(request, response) {
    Stripe.Customers.create({
        description: request.params.fullName,
        email: request.params.email,
        card: request.params.token,
        metadata: {
            name: request.params.fullName,
            phone: request.params.phone
        }
    }, {
        success: function (httpResponse) {
            var Donor = Parse.Object.extend("Donor");
            var newDonor = new Donor();
            newDonor.set("stripeCustomerId", httpResponse["id"]);
            newDonor.set("email", request.params.email);
            newDonor.save(null, {
                success: function (newDonorAgain) {
                    stripeCreatedOrUpdatedCustomer(request, response, httpResponse);
                },
                error: function (newDonorAgain, error) {
                    response.error(error);
                },
                useMasterKey: true
            });

        },
        error: function (httpResponse) {
            response.error("Uh oh, something went wrong.");
        }
    });
}

// Charge customer
function stripeCreatedOrUpdatedCustomer(request, response, httpResponse) {
    Stripe.Charges.create({
        amount: request.params.amount, // in cents
        currency: request.params.currency,
        customer: httpResponse["id"]
    },{
        success: function(httpResponse) {
            response.success("Donation received!");
        },
        error: function(httpResponse) {
            response.error("Uh oh, something went wrong.");
        }
    });
}