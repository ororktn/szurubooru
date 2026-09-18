#!/usr/bin/dumb-init /bin/sh
set -e
cd /opt/app/server

alembic upgrade head

echo "Starting szurubooru API on port ${BACKEND_PORT} - Running on ${THREADS_WAITRESS} threads"
exec hupper -w /opt/app/server -m waitress --listen=*:${BACKEND_PORT} --threads=${THREADS_WAITRESS} szurubooru.facade:app 