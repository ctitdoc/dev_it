
public type DockerComposeContent record {
    string version;
    map<map<json>> services;
    map<json> volumes;
    map<json> networks;
};
