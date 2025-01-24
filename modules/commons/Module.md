Provides a "cloud deploy files" processing api
[//]: # (above is the module summary)

# Module Overview
Provides an extensible set of functions to :
* add, update or delete parts of json dockefiles, yaml docker compose files and json composer files (other file types can be added),
* convert them from json to docker, yaml to json and json to yaml,
* generate new files from those ones, like "composer update package" scripts,
* configure via json files, various processing based the previous functions.
Take a look at srv_opportunity module for an example.