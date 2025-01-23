#!/bin/bash -xv
pushd /home/franck/dev/dev_it
dockerfile2json /home/franck/dev/srv_opportunity/Dockerfile > /home/franck/dev/srv_opportunity/Dockerfile.json
bal run /home/franck/dev/dev_it -- ./modules/srv_opportunity/runConfiguration.json
cp /home/franck/dev/srv_opportunity/local_dev/entrypoint.sh /home/franck/dev/srv_opportunity/entrypoint.sh
cp /home/franck/dev/srv_opportunity/local_dev/docker-compose.override.yml /home/franck/dev/srv_opportunity/docker-compose.override.yml
popd