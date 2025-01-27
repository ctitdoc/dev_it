Manages dev environnment of srv_opportunity app.

# Module Overview
Manages dev environnment of srv_opportunity app:
* dev_setup_srv_opportunity.sh change some deploy files to dev with locally deployed bundles;
* runConfiguration.json configure the changes to perform, namely the bundles to deploy locally;
    * a switchable option enables/disables the creation of a script to run the bundle updates with composer;
* remove_dev_setup_srv_opportunity.sh rollback the local bundles deployed for released versions;
* releaseConfiguration.json configures the releases to deploy;
