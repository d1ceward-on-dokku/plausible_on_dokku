ARG PLAUSIBLE_VERSION="v3.0.1"

FROM ghcr.io/plausible/community-edition:$PLAUSIBLE_VERSION

EXPOSE 8000/tcp

CMD \
  export PORT=8000 && \
  export CLICKHOUSE_DATABASE_URL=$(echo $CLICKHOUSE_URL | sed 's#clickhouse://#http://#' | sed 's#:9000/#:8123/#') && \
  sleep 10 && \
  /entrypoint.sh db createdb && \
  /entrypoint.sh db migrate && \
  /entrypoint.sh run
