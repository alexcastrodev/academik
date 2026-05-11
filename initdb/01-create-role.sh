#!/bin/bash

ENV_PATH="/mnt/ssd/@docker/academik/.env"
set -a
source "$ENV_PATH"
set +a


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  ALTER DATABASE "${POSTGRES_DB}" OWNER TO "${POSTGRES_USER}";
EOSQL
