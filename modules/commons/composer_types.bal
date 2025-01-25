
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
    map<string?> 'psr_4?;
};

// quelques essais infructueux pour utliser une map avec des objet typés, qui préserve l'ordre des clé de la map json originale
// alors qu'une map convertie en record ne le préserve pas: voir:
// https://github.com/ballerina-platform/ballerina-spec/issues/897
//public type ComposerItem json|ComposerRequire|ComposerRepository[]|ComposerAutoloadAlt;
//public type ComposerContentAlt map<json|ComposerRequire|ComposerRepository[]|ComposerAutoloadAlt>;
//public type ComposerContentAlt record {|ComposerRequire require; ComposerRepository[] repositories; ComposerAutoloadAlt autoload ; json...;|};

//public type ComposerRequire  map<string?>;

//public type ComposerAutoloadAlt record {| map<string?> 'psr_4? ; json...;|};

