#!/bin/bash

set -euxo pipefail

if [[ -z $STACK_VERSION ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [STACK_VERSION] not set\033[0m"
  exit 1
fi

PLUGINS_STR=`echo ${PLUGINS} | sed -e 's/\n/ /g'`
PLUGIN_INSTALL_CMD=""

if [ "x${PLUGINS_STR}" != "x" ]; then
    ARRAY=(${PLUGINS_STR})
    for i in "${ARRAY[@]}"
    do
        PLUGIN_INSTALL_CMD+="elasticsearch-plugin install --batch ${i} && "
    done
fi

docker run \
  --rm \
  --env "node.name=es1" \
  --env "cluster.name=docker-elasticsearch" \
  --env "cluster.initial_master_nodes=es1" \
  --env "discovery.seed_hosts=es1" \
  --env "cluster.routing.allocation.disk.threshold_enabled=false" \
  --env "bootstrap.memory_lock=true" \
  --env "ES_JAVA_OPTS=-Xms2g -Xmx2g -Dhttp.proxyHost=${PROXY_HTTP_HOST} -Dhttp.proxyPort=${PROXY_HTTP_PORT} -Dhttps.proxyHost=${PROXY_HTTPS_HOST} -Dhttps.proxyPort=${PROXY_HTTPS_PORT}" \
  --env "xpack.security.enabled=false" \
  --env "xpack.license.self_generated.type=basic" \
  --ulimit nofile=65536:65536 \
  --ulimit memlock=-1:-1 \
  --publish "9200:9200" \
  --detach \
  --name="es1" \
  --entrypoint="" \
  docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION} \
  /bin/sh -vc "${PLUGIN_INSTALL_CMD} /usr/local/bin/docker-entrypoint.sh"
  
sleep 60

echo "Elasticsearch up and running"
