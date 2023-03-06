FROM docker:stable
RUN apk add --no-cache --upgrade bash
COPY run-elasticsearch.sh /run-elasticsearch.sh
ENTRYPOINT ["/run-elasticsearch.sh"]
