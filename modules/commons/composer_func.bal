import ballerina/io;

public function makeBundlesChanges(map<json>? runConfig) returns error? {
    string composerFileIn = check (<string?>runConfig["composerFileIn"] ?: "composer.json");
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${composerFileIn} to ${composerFileOut}`);
    map<json> jsonContent = check (check io:fileReadJson(composerFileIn)).cloneWithType();
    ComposerContent composerContent = check jsonContent.cloneWithType();
    json[] bundles = check runConfig["bundles"].ensureType();
    foreach json bundleConf in bundles {
        map<json> bundle = check bundleConf.ensureType();
        check changeBundleReleaseConstraintAlt(composerContent, <string> bundle["bundle"], <string> bundle["releaseConstraint"]);
        check changeBundleRepository(composerContent,
                        <string> bundle["repoUrlPattern"],
                        <string> bundle["repoType"],
                        <string> bundle["repoUrl"]);
        
        if ! (runConfig["bundlesUpdateFile"] is ()) {
            check addBundleUpdateCmd(<string> bundle["bundle"], <string> runConfig["bundlesUpdateFile"]);
        }
    }
    check changePsr4(composerContent);
    jsonContent["require"] = composerContent.require.toJson();
    jsonContent["autoload"] = composerContent.autoload.toJson();
    jsonContent["repositories"] = composerContent.repositories.toJson();

    return jsonFormater(jsonContent, composerFileOut);
}

public function changeBundleReleaseConstraintAlt(ComposerContent composerContent, string bundle, string constraint) returns error? {
    composerContent.require[bundle] = constraint;
}

public function changePsr4(ComposerContent composerContent) returns error? {
    composerContent.autoload.'psr\-4 = {
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

public function changeBundleRepository(ComposerContent composerContent, string bundleRepository, string repoType, string repoUrl) returns error? {
    ComposerRepository[] bundleRepos = from var repository in composerContent.repositories
        where (<string>check repository.url).includesMatch(re `(?i:${bundleRepository})`)
        select repository;
    bundleRepos[0].url = repoUrl;
    bundleRepos[0].'type = repoType;
}