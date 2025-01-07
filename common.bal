import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

//see https://ballerina.io/learn/by-example/http-client-send-request-receive-response/

// public function OFPost(http:Client apiClient, string apiUrl, string route, anydata body, map<string>? headers) returns json|error {
//     io:println("call POST " + apiUrl + route);
//     io:println("with body:");
//     io:println(body);
//     json response = ();
//     if (headers != ()) {
//     response = check apiClient->post(route, body, headers);
//     } else {
//         response = check apiClient->post(route, body, headers);
//     }
//     io:println("receive response:");
//     io:println(response);
//     io:println();
//     return response;
// }

public function OFUpdate(string updateMethod, http:Client apiClient, string apiUrl, string route, anydata body, map<string>? headers) returns json|error {
    io:println("call " + updateMethod + " " + apiUrl + route);
    io:println("with body:");
    io:println(body);
    json response = ();
    if (headers != ()) {
        if (updateMethod == "POST") {
            response = check apiClient->post(route, body, headers);
        } else if (updateMethod == "PATCH") {
            response = check apiClient->patch(route, body, headers);
        }
    } else {
        if (updateMethod == "PATCH") {
            response = check apiClient->post(route, body);
        } else if (updateMethod == "PATCH") {
            response = check apiClient->patch(route, body);
        }
    }
    io:println("receive response:");
    io:println(response);
    io:println();
    return response;
}

public function OFPatch (http:Client apiClient, string apiUrl, string route, anydata body, map<string>? headers) returns json|error {
    return OFUpdate("PATCH", apiClient, apiUrl, route, body, headers);
}

public function OFPost (http:Client apiClient, string apiUrl, string route, anydata body, map<string>? headers) returns json|error {
    return OFUpdate("POST", apiClient, apiUrl, route, body, headers);
}

public function prGet(string url, anydata response) {
    io:println("call GET " + url);
    io:println("receive response:");
    io:println(response);
    io:println();
}

public function getDbClient() returns mysql:Client|sql:Error {
    final mysql:Client|sql:Error dbClient =  new("localhost","root","root","srv_opportunity",3310);
    return dbClient;
}

isolated function getOpportunities(mysql:Client dbClient) returns SOOpp[] {
    SOOpp[] opportunities = [];
    stream<SOOpp, error?> resultStream = dbClient->query(
        `SELECT openflex_opportunity_id, status FROM opportunity`
    );
    error? status = from SOOpp opportunity in resultStream
        do {
            opportunities.push(opportunity);
        };
    status = resultStream.close();
    return opportunities;
}

public  function play (string scenarioId) returns boolean {
    return scenarios.indexOf(scenarioId) != () || scenarios.indexOf("all") != ();
}

public  function shouldBeRan(string scenarioId) returns boolean {
    return runConfiguration[scenarioId] != () || runConfiguration["all"] != ();
}

public  function getRunConfiguration(string scenarioId) returns map<json>? {
    map<json> config = checkpanic runConfiguration[scenarioId].ensureType();
    return config;
}