import thisarug/prettify;
import ballerina/file;
import ballerina/io;

public function jsonFormater(json jsonContent, string composerFileOut) returns error? {
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