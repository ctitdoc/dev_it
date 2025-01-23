public type DockerComposeContent record {
    string version;
    map<map<json>> services;
    map<json> volumes;
    map<json> networks;
};
public type DockerStatment record {
    string original;
    string cmd;
    string[] value;
};
