#!/bin/bash -xv
pushd /home/franck/dev/srv_opportunity
rm -f /home/franck/dev/srv_opportunity/entrypoint.sh
rm -f /home/franck/dev/srv_opportunity/docker-compose.override.yml
git checkout Dockerfile
pushd /home/franck/dev/dev_it
bal run /home/franck/dev/dev_it -- ./releaseConfiguration.json
popd
composer update ithis/openflex-bundle 
popd