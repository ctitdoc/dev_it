import ballerina/io;
import thisarug/prettify;
import ballerina/file;

// This typed version alternative of composer_func.bal is not used because ballerina does not support today
// the generation of a typed record with its keys generated in the same order as the original json content
// see FIXME comment in jsonFormaterAlt function.

public function makeBundlesChangesAlt(map<json>? runConfig) returns error? {
    string composerFileIn = check (<string?>runConfig["composerFileIn"] ?: "composer.json");
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${composerFileIn} to ${composerFileOut}`);
    json jsonContent = check io:fileReadJson(composerFileIn);
    ComposerContent composerContent = check jsonContent.cloneWithType();
    json[] bundles = check runConfig["bundles"].ensureType();
    foreach json bundleConf in bundles {
        map<json> bundle = check bundleConf.ensureType();
        check changeBundleReleaseConstraintAlt(composerContent, <string> bundle["bundle"], <string> bundle["releaseConstraint"]);
        check changeBundleRepositoryAlt(composerContent, 
                        <string> bundle["repoUrlPattern"],
                        <string> bundle["repoType"],
                        <string> bundle["repoUrl"]);
        
        if ! (runConfig["bundlesUpdateFile"] is ()) {
            check addBundleUpdateCmdAlt(<string> bundle["bundle"], <string> runConfig["bundlesUpdateFile"]);
        }
    }
    check changePsr4Alt(composerContent);
    return jsonFormaterAlt(composerContent, runConfig);
}

public function changeBundleReleaseConstraintAlt(ComposerContent composerContent, string bundle, string constraint) returns error? {
    composerContent.require[bundle] = constraint;
}

public function changePsr4Alt(ComposerContent composerContent) returns error? {
    composerContent.autoload.'psr_4 = {
            "App\\\\": "src/"
        };
}

public function addBundleUpdateCmdAlt(string bundle, string bundlesUpdateFile) returns error? {
    checkpanic io:fileWriteString(
        bundlesUpdateFile,
        string `composer update ${bundle}
`, 
        io:APPEND);
}

public function changeBundleRepositoryAlt(ComposerContent composerContent, string bundleRepository, string repoType, string repoUrl) returns error? {
    ComposerRepository[] bundleRepos = from var repository in composerContent.repositories
        where (<string>check repository.url).includesMatch(re `(?i:${bundleRepository})`)
        select repository;
    bundleRepos[0].url = repoUrl;
    bundleRepos[0].'type = repoType;
}

//FIXME: Ballerina limitation: typed records like ComposerContent do not output the original json keys in the salme order
public function jsonFormaterAlt(ComposerContent composerContent, map<json>? runConfig) returns error? {
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    string prettified = prettify:prettify(<json> composerContent);

    if (composerFileOut == "STDOUT") {
        io:print(prettified);
    } else {
        if (checkpanic file:test(composerFileOut, file:EXISTS)) {
            checkpanic file:remove(composerFileOut);
        }
        checkpanic io:fileWriteString(composerFileOut, prettified);
    }
}