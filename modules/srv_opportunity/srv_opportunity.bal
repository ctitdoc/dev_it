import ballerina/io;
import dev_it.commons as co;
import ballerina/data.yaml as yml;
import ballerina/yaml;
import ballerina/file;


public function srv_opportunity(string runConfigurationFile) returns error? {

    check co:setRunConfiguration(check io:fileReadJson(runConfigurationFile));

    if (co:shouldBeRan("makeSrvOppDockerDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerDev...");

        check co:toDocker([makeSrvOppDockerDev], co:getRunConfiguration("makeSrvOppDockerDev"));
    }
    if (co:shouldBeRan("makeBundlesDev")) {
        io:fprintln(io:stderr, "running makeBundlesDev...");
        check co:makeBundlesChanges(co:getRunConfiguration("makeBundlesDev"));
    }
    if (co:shouldBeRan("makeSrvOppDockerComposeDev")) {
        io:fprintln(io:stderr, "running makeSrvOppDockerComposeDev...");
        check makeSrvOppDockerComposeDev(co:getRunConfiguration("makeSrvOppDockerComposeDev"));
    }
    if (co:shouldBeRan("makeBundlesRelease")) {
        io:fprintln(io:stderr, "running makeBundlesRelease...");
        check co:makeBundlesChanges(co:getRunConfiguration("makeBundlesRelease"));
    }   
}

public function makeSrvOppDockerDev(co:DockerStatment[] statments, map<json>? runConfig) {
    co:dockerFormater(
            co:addEntryPointStatments(
                    co:removeComposerDumpAutoloadStatment(
                            co:removeComposerInstallStatment(statments))), runConfig);
}

public function makeSrvOppDockerComposeDev(map<json>? runConfig) returns error? {
    string dockerComposeFileIn = check (<string?>runConfig["dockerComposeFileIn"] ?: "docker-compose_out.yml");
    string dockerComposeFileOut = check (<string?>runConfig["dockerComposeFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${dockerComposeFileIn} to ${dockerComposeFileOut}`);
    json jsonContent = check yaml:readFile(dockerComposeFileIn);
    co:DockerComposeContent dockerComposeContent = check jsonContent.cloneWithType();
    dockerComposeContent.services["db_srv_opportunity"]["healthcheck"] = {
        "test": "['CMD', 'mysqladmin', 'ping', '-h', 'localhost', '-u', 'root', '-proot']",
        "interval": "10s",
        "timeout": "5s",
        "retries": 3
    };
    string yamlContent = check yml:toYamlString(dockerComposeContent, {forceQuotes: true});

    if (dockerComposeFileOut == "STDOUT") {
        io:println(yamlContent);
    } else {
        if (checkpanic file:test(dockerComposeFileOut, file:EXISTS)) {
            checkpanic file:remove(dockerComposeFileOut);
        }
        checkpanic io:fileWriteString(dockerComposeFileOut, yamlContent);
    }
}

