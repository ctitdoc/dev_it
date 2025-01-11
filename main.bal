import ballerina/io;

public function main(string runConfigurationFile) returns error? {
    runConfiguration = check io:fileReadJson(runConfigurationFile).ensureType();
    if (shouldBeRan("makeSrvOppDockerDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerDev...");

        check toDocker([makeSrvOppDockerDev], getRunConfiguration("makeSrvOppDockerDev"));
    }
    if (shouldBeRan("makeBundlesDev")) {
        io:fprintln(io:stderr, "running makeBundlesDev...");
        check makeBundlesDev(getRunConfiguration("makeBundlesDev"));
    }
    if (shouldBeRan("makeSrvOppDockerComposeDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerComposeDev...");
        check makeSrvOppDockerComposeDev(getRunConfiguration("makeSrvOppDockerComposeDev"));
    }
    if (shouldBeRan("makeSrvOppOFBundleRelease")) {
        io:fprintln(io:stderr, "running makeSrvOppOFBundleRelease...");
        check makeSrvOppOFBundleRelease(getRunConfiguration("makeSrvOppOFBundleRelease"));
    }   
}
