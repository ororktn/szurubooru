#!/usr/bin/dumb-init /bin/sh
set -e
cd /opt/app/server

alembic upgrade head

echo "Starting szurubooru API on port ${BACKEND_PORT} - Running on ${THREADS} threads"
exec waitress-serve-3 --listen "*:${BACKEND_PORT}" --threads ${THREADS} szurubooru.facade:app
