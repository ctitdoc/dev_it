import ballerina/data.yaml as yml;
import ballerina/file;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/yaml;

import thisarug/prettify;

# Description.
#
# + jsonDockerFile - parameter description  
# + dockerDockerFile - parameter description  
# + transformers - parameter description
# + return - return value description
public function toDocker((function (DockerStatment[] statments, map<json>? runConfig = {}))[] transformers = [dockerFormater], map<json>? runConfig = {}) returns error? {
    string jsonDockerFile = check (<string?>runConfig["jsonDockerFile"] ?: "Dockerfile.json");
    string dockerDockerFile = check (<string?>runConfig["dockerDockerFile"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${jsonDockerFile} to ${dockerDockerFile}`);
    json file = check io:fileReadJson(jsonDockerFile);
    DockerStatment[] statments = check file.cloneWithType();
    foreach function transformer in transformers {
        transformer(statments, runConfig);
    }
}

public function makeSrvOppDockerDev(DockerStatment[] statments, map<json>? runConfig) {
    dockerFormater(
            addEntryPointStatments(
                    removeComposerDumpAutoloadStatment(
                            removeComposerInstallStatment(statments))), runConfig);
}

public function removeComposerInstallStatment(DockerStatment[] statments) returns DockerStatment[] {
    regexp:RegExp cmdPattern = re `(?i:run)`;
    regexp:RegExp originalPattern = re `(?i:composer\s+install)`;
    return from var statment in statments
        where !(statment.cmd.includesMatch(cmdPattern) && statment.original.includesMatch(originalPattern))
        select statment;
};

public function removeComposerDumpAutoloadStatment(DockerStatment[] statments) returns DockerStatment[] {
    regexp:RegExp cmdPattern = re `(?i:run)`;
    regexp:RegExp originalPattern = re `(?i:composer\s+dump-autoload)`;
    return from var statment in statments
        where !(statment.cmd.includesMatch(cmdPattern) && statment.original.includesMatch(originalPattern))
        select statment;
};

public function dockerFormater(DockerStatment[] statments, map<json>? runConfig = {}) {
    string dockerDockerFile = (<string?>runConfig["dockerDockerFile"] ?: "STDOUT");
    if (dockerDockerFile == "STDOUT") {
        foreach DockerStatment statment in statments {
            io:println(`${statment.original}`);
            io:println("");
        }
    } else {
        string[] lines = [""];
        foreach DockerStatment statment in statments {
            lines.push(string `${statment.original}`);
            lines.push("");
        }
        if (checkpanic file:test(dockerDockerFile, file:EXISTS)) {
            checkpanic file:remove(dockerDockerFile);
        }
        checkpanic io:fileWriteLines(dockerDockerFile, lines);
    }
}

public function addEntryPointStatments(DockerStatment[] statments) returns DockerStatment[] {
    regexp:RegExp originalPattern = re `(?i:from\s+symfony_php)`;
    DockerStatment[] entryPointStatments = [
        {
            "cmd": "COPY",
            "original": "COPY entrypoint.sh /usr/local/bin/entrypoint.sh",
            "value": [
                "entrypoint.sh",
                "/usr/local/bin/entrypoint.sh"
            ]
        },
        {
            "cmd": "RUN",
            "original": "RUN chmod +x /usr/local/bin/entrypoint.sh",
            "value": [
                "chmod +x /usr/local/bin/entrypoint.sh"
            ]
        }
    ];

    DockerStatment[] result = [];
    foreach DockerStatment statment in statments {
        if statment.original.includesMatch(originalPattern) {
            result.push(...entryPointStatments);
            result.push(statment);
        } else {
            result.push(statment);
        }
    }
    return result;
}

public function makeSrvOppOFBundleDev(map<json>? runConfig) returns error? {
    string composerFileIn = check (<string?>runConfig["composerFileIn"] ?: "composer.json");
    string composerFileOut = check (<string?>runConfig["composerFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${composerFileIn} to ${composerFileOut}`);
    json jsonContent = check io:fileReadJson(composerFileIn);
    check changeBundleReleaseConstraint(jsonContent, "ithis/openflex-bundle", "*");
    check changeBundleRepository(jsonContent, "ithis-openflex-bundle.git", "path", "/srv/app/bundles/ithis-openflex-bundle");
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

public function makeSrvOppDockerComposeDev(map<json>? runConfig) returns error? {
    string dockerComposeFileIn = check (<string?>runConfig["dockerComposeFileIn"] ?: "docker-compose_out.yml");
    string dockerComposeFileOut = check (<string?>runConfig["dockerComposeFileOut"] ?: "STDOUT");
    io:fprintln(io:stderr, `Converting ${dockerComposeFileIn} to ${dockerComposeFileOut}`);
    json jsonContent = check yaml:readFile(dockerComposeFileIn);
    DockerComposeContent dockerComposeContent = check jsonContent.cloneWithType();
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
