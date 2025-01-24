import ballerina/io;
import thisarug/prettify;
import ballerina/file;


public function makeBundlesChanges(map<json>? runConfig) returns error? {
    string composerFileIn = check (<string?>runConfig["composerFileIn"] ?: "composer.json");
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${composerFileIn} to ${composerFileOut}`);
    json jsonContent = check io:fileReadJson(composerFileIn);
    json[] bundles = check runConfig["bundles"].ensureType();
    foreach json bundleConf in bundles {
        map<json> bundle = check bundleConf.ensureType();
        check changeBundleReleaseConstraint(jsonContent, <string> bundle["bundle"], <string> bundle["releaseConstraint"]);
        check changeBundleRepository(jsonContent, 
                        <string> bundle["repoUrlPattern"],
                        <string> bundle["repoType"],
                        <string> bundle["repoUrl"]);
        
        if ! (runConfig["bundlesUpdateFile"] is ()) {
            check addBundleUpdateCmd(<string> bundle["bundle"], <string> runConfig["bundlesUpdateFile"]);
        }
    }
    check changePsr4(jsonContent);
    return jsonFormater(jsonContent, runConfig);
}

public function changeBundleReleaseConstraint(json composerContent, string bundle, string constraint) returns error? {
    map<json> require = check composerContent.require.ensureType();
    require[bundle] = constraint;
}

public function changePsr4(json composerContent) returns error? {
    map<json> autoload = check composerContent.autoload.ensureType();
    autoload["psr-4"] = {
            "App\\\\": "src/"
        };
}

public function addBundleUpdateCmd(string bundle, string bundlesUpdateFile) returns error? {
    checkpanic io:fileWriteString(
        bundlesUpdateFile,
        string `composer update ${bundle}
`, 
        io:APPEND);
}

public function changeBundleRepository(json composerContent, string bundleRepository, string repoType, string repoUrl) returns error? {
    json[] repos = check composerContent.repositories.ensureType();
    json bundelRepository = from var repository in repos
        where (<string>check repository.url).includesMatch(re `(?i:${bundleRepository})`)
        select repository;
    json[] repositories = check bundelRepository.ensureType();
    map<json> theRepo = check repositories[0].ensureType();
    theRepo["url"] = repoUrl;
    theRepo["type"] = repoType;
}

public function jsonFormater(json jsonContent, map<json>? runConfig) returns error? {
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    string prettified = prettify:prettify(jsonContent);

    if (composerFileOut == "STDOUT") {
        io:print(prettified);
    } else {
        if (checkpanic file:test(composerFileOut, file:EXISTS)) {
            checkpanic file:remove(composerFileOut);
        }
        checkpanic io:fileWriteString(composerFileOut, prettified);
    }
}