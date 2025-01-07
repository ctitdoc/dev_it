import ballerina/io;

public function main(string runConfigurationFile) returns error? {
    runConfiguration = check io:fileReadJson(runConfigurationFile).ensureType();
    if (shouldBeRan("makeSrvOppDockerDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerDev...");

        check toDocker([makeSrvOppDockerDev], getRunConfiguration("makeSrvOppDockerDev"));
    }
    if (shouldBeRan("makeSrvOppOFBundleDev")) {
        io:fprintln(io:stderr, "running makeSrvOppOFBundleDev...");
        check makeSrvOppOFBundleDev(getRunConfiguration("makeSrvOppOFBundleDev"));
    }
    if (shouldBeRan("makeSrvOppDockerComposeDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerComposeDev...");
        check makeSrvOppDockerComposeDev(getRunConfiguration("makeSrvOppDockerComposeDev"));
    }
   
}
