import ballerina/io;

public function main(string runConfigurationFile) returns error? {
    runConfiguration = check io:fileReadJson(runConfigurationFile).ensureType();
    if (shouldBeRan("makeSrvOppDockerDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerDev...");

        check toDocker([makeSrvOppDockerDev], getRunConfiguration("makeSrvOppDockerDev"));
    }
    if (shouldBeRan("makeBundlesDev")) {
        io:fprintln(io:stderr, "running makeBundlesDev...");
        check makeBundlesChanges(getRunConfiguration("makeBundlesDev"));
    }
    if (shouldBeRan("makeSrvOppDockerComposeDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerComposeDev...");
        check makeSrvOppDockerComposeDev(getRunConfiguration("makeSrvOppDockerComposeDev"));
    }
    if (shouldBeRan("makeBundlesRelease")) {
        io:fprintln(io:stderr, "running makeBundlesRelease...");
        check makeBundlesChanges(getRunConfiguration("makeBundlesRelease"));
    }   
}
