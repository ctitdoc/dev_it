
public type ComposerContent record {
    map<string?> require;
    ComposerRepository[] repositories;
    ComposerAutoload autoload;
};
public type ComposerRepository record {
    string 'type;
    string url;
};

public type ComposerAutoload record {
    map<string?> 'psr\-4?;
};