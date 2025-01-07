#!/bin/bash -xv
pushd /home/franck/dev/srv_opportunity
rm -f /home/franck/dev/srv_opportunity/entrypoint.sh
rm -f /home/franck/dev/srv_opportunity/docker-compose.override.yml
git checkout Dockerfile composer.json
composer update ithis/openflex-bundle 
popd