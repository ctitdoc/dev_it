import ballerina/http;
import ballerina/io;

public function orig() returns error? {

    io:println("srv opportunity API calls tests");

         if(play("test")) {
            http:Client OFAuthFRClient = check new ("https://identity-api.openflex-preprod.eu");
            json OFFRCredentials = {
                "id": "000fq119",
                "password": "z04vWHpVAnF#PU"
            };
            json response = check OFPost(OFAuthFRClient, "https://identity-api.openflex-preprod.eu",  "/providers/entities", OFFRCredentials, {});
            EntityResponse entityReponse = check response.cloneWithType();
            http:Client OFSellingClientFR = check new ("https://selling-api.openflex-preprod.eu");
            int[] entityIds = from Entity entity in entityReponse.items select entity.id;
            foreach int entityId  in  entityIds {
                string route = "/auth/providers/sign-in";
                response = check OFPost(OFAuthFRClient, "https://identity-api.openflex-preprod.eu", route, {
                "id": "000fq119",
                "password": "z04vWHpVAnF#PU",
                "entityId": "300" //entityId.toString()
                }, {});
                string tokenFR = check response.token;
                map<string> headersFR = {"Authorization": "Bearer " + tokenFR};
                //io:println("call GET " + "https://selling-api.openflex-preprod.eu" + "/vehicles/cars?pointOfSales[]=454&total=true");
                response = check OFSellingClientFR->get("/vehicles/cars?pointOfSales[]=454&chassis=WVGZZZ5NZCW571130&total=true", headersFR);
                prGet("https://selling-api.openflex-preprod.eu" + "/vehicles/cars?pointOfSales[]=454&chassis=WVGZZZ5NZCW571130&total=true", response);
                if (play("test")) {
                    return;
                }
                response = check OFAuthFRClient->get("/point-of-sales", headersFR);
                prGet("https://identity-api.openflex-preprod.eu" + "/point-of-sales", response);
                //response = check OFSellingClientFR->/opportunities(headersFR, total = true);
                //prGet("https://selling-api.openflex.eu" + "/opportunities", response);
            }
            return;
        }

    //conf
    json|io:Error conf = getConf();
    if (conf is error) {
        return conf;
    } else {
        string sellingUrl = check getContainerEnvVar(conf, "php-fpm", "OPENFLEX_SELLING_URI");
        io:println(sellingUrl);
        string authUrl = check getContainerEnvVar(conf, "php-fpm", "OPENFLEX_AUTH_SERVER_URI");
        io:println(authUrl);
        string gatewayUrl = check getContainerEnvVar(conf, "php-fpm", "OPENFLEX_GATEWAY_URI");
        io:println(gatewayUrl);
        io:println();


        //authent providers
        json OFCredentials = check getJsonOFAuthCredentials();

        http:Client OFAuthClient = check new (authUrl);

        if (play("OFpwd")) {
            json response = check OFPatch(OFAuthClient, authUrl, "/auth/providers/password/Ba80O862HzEYXJVcyjnoZVnDr7xreoeG", { "password": "z04vWHpVAnF#PU" }, {});
            return;
        }

        string route = "/auth/providers/sign-in";

        json response = check OFPost(OFAuthClient, authUrl, route, OFCredentials, {});

        string token = check response.token;
        map<string> headers = {"Authorization": "Bearer " + token};

        string? email = "";
        if (play("salesPerson")) {
            //get users by point of sale ID
            UserResponse users = check OFAuthClient->get("/users?pointOfSaleIds[]=155&groupTypes[]=3&total=true", headers);
            prGet(sellingUrl + "/users?pointOfSaleIds[]=155&groupTypes[]=3&total=true", users);
            email = users.items[0].email;
        }

        http:Client OFSellingClient = check new (sellingUrl);


        //  if(play("test2")) {
        //         http:Client OFAuthFRClient = check new ("https://identity-api.openflex.eu");
        //         route = "/auth/providers/sign-in";
        //         response = check OFPost(OFAuthFRClient, "https://identity-api.openflex.eu", route, {
        //         "id": "000et092",
        //         "password": "8b@KddHDD8b!hE",
        //         "entityId": "1645"
        //         }, {});
        //         string tokenFR = check response.token;
        //         map<string> headersFR = {"Authorization": "Bearer " + tokenFR};
        //         //response = check OFAuthFRClient->get("/point-of-sales", headersFR);
        //         //prGet("https://identity-api.openflex.eu" + "/point-of-sales", response);
        //         //response = check OFSellingClientFR->/opportunities(headersFR, total = true);
        //         //prGet("https://selling-api.openflex.eu" + "/opportunities", response);

        //         json jsonOpp = check getJson("OpportunityFR.json");
        //         Opportunity opportunity = check jsonOpp.cloneWithType();
        //         route = "/offers";
        //         http:Client OFGatewayClient = check new ("https://gateway-api.openflex.eu");
        //         response = check OFPost(OFGatewayClient, "https://gateway-api.openflex.eu", route, opportunity, headersFR);

        //     return;
        // }

       if (play("createOpp")) {
            json jsonOpp = check getJson("Opportunity.json");
            Opportunity opportunity = check jsonOpp.cloneWithType();

            //get car by chassis and create opportunity
            //see https://ballerina.io/learn/by-example/http-client-send-request-receive-response/
            VehResponse vehResp = check OFSellingClient->/vehicles/cars(headers, chassis = <string>opportunity?.chassis, total = true);
            prGet(sellingUrl + "/vehicles/cars?chassis=" + <string>opportunity?.chassis + "&total=true", vehResp);
            int vehId = vehResp.items[0].id;

            route = "/offers";
            opportunity.stockCarId = vehId;
            if (play("salesPerson")) {
                opportunity.attributedUser = {"email": email};
            }
            http:Client OFGatewayClient = check new (gatewayUrl);

            response = check OFPost(OFGatewayClient, gatewayUrl, route, opportunity, headers);

            //adds comment
            OpportunityResponse ofResponse = check response.cloneWithType();

            route = "/opportunities/" + ofResponse.opportunityId + "/comments";
            json body = {
                "comment": "test Franck ajout par API commentaire de l'offre ID " + ofResponse.id
            };

            response = check OFPost(OFSellingClient, sellingUrl, route, body, headers);

            //get opportunit by ID
            json opp = check OFSellingClient->/opportunities/[ofResponse.opportunityId](headers, total = true);
            prGet(sellingUrl + "/opportunities/" + ofResponse.opportunityId + "?total=true", opp);
            OFOffersResponse offers = check OFSellingClient->/opportunities/[ofResponse.opportunityId]/offers(headers);
            prGet(sellingUrl + "/opportunities/" + ofResponse.opportunityId + "/offers?total=true", offers);
            json offer = check OFSellingClient->get(string `/offers?ids[]=${offers.items[0].id}`, headers);
            prGet(string `${sellingUrl}/offers?ids[]=${offers.items[0].id}`, offer);
        }
    }

    if (play("oppStatus")) {
        var db_srv_opportunity = check getDbClient();
        SOOpp[] opps = getOpportunities(db_srv_opportunity);
        io:println(opps);
    }

}
