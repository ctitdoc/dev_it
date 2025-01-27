import ballerina/file;
import ballerina/io;
import ballerina/lang.regexp;

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

public function removeComposerInstallStatment(DockerStatment[] statments) returns DockerStatment[] {
    return from var statment in statments
        where !(
                  statment.cmd.includesMatch(re `(?i:run)`) &&
                  statment.original.includesMatch(re `(?i:composer\s+install)`)
                )
        select statment;
};

public function removeComposerDumpAutoloadStatment(DockerStatment[] statments) returns DockerStatment[] {
    return from var statment in statments
        where !(
                  statment.cmd.includesMatch(re `(?i:run)`) &&
                  statment.original.includesMatch(re `(?i:composer\s+dump-autoload)`))
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