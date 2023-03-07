#!/bin/sh

set -euxo pipefail

if [[ -z $STACK_VERSION ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [STACK_VERSION] not set\033[0m"
  exit 1
fi

docker network create elastic

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
  --network=elastic \
  --name="es1" \
  --entrypoint="" \
  docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION} \
  /bin/sh -vc "elasticsearch-plugin install ingest-attachment /usr/local/bin/docker-entrypoint.sh"

docker run \
  --network elastic \
  --rm \
  appropriate/curl \
  --max-time 240 \
  --retry 120 \
  --retry-delay 2 \
  --retry-connrefused \
  --show-error \
  http://localhost:9200

sleep 10

echo "Elasticsearch up and running"
