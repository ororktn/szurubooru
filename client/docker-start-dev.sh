#!/usr/bin/dumb-init /bin/sh

# Integrate environment variables
sed -i "s|__BACKEND__|${BACKEND_HOST}|" \
  /etc/nginx/nginx.conf
sed -i "s|__LISTEN_PORT__|${FRONTEND_PORT}|g" \
  /etc/nginx/nginx.conf
sed -i "s|__BACKEND_PORT__|${BACKEND_PORT}|" \
  /etc/nginx/nginx.conf
sed -i "s|__BASEURL__|${BASE_URL}|g" \
  /opt/app/client/public/index.htm \
  /opt/app/client/public/manifest.json



# Start server
exec nginx & yarn run watch --modules-folder ${NODE_PATH}
