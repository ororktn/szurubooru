### BUILDER ###
FROM --platform=$BUILDPLATFORM alpine:latest AS builder

ARG PUID=1000
ARG PGID=1000
ENV NODE_PATH=/opt/app/node_modules

# Init homedir
RUN mkdir -p /opt/app
WORKDIR /opt/app

# Add dependencies
RUN apk add --no-cache --update nodejs \
    dumb-init \
    yarn

RUN addgroup -g ${PGID} app \
    && adduser -SDH -h /opt/app -g '' -G app -u ${PUID} app \
    && chown -R app:app /opt/app
USER app

RUN mkdir -p /opt/app/client

WORKDIR /opt/app/client
COPY --chown=app . ./
RUN yarn install --modules-folder ${NODE_PATH}

ARG BUILD_INFO="docker-latest"
ARG CLIENT_BUILD_ARGS=""
RUN BASE_URL="__BASEURL__" yarn run build --modules-folder ${NODE_PATH} --gzip ${CLIENT_BUILD_ARGS}


### DEV ENV ###
FROM builder AS development

WORKDIR /opt/app/client

# Add dev dependencies
USER root
RUN apk add --no-cache --update nginx \
    git
RUN chown -R app:app /var/log/nginx /var/lib/nginx /etc/nginx
RUN ln -sf /opt/app/client/nginx.conf.docker /etc/nginx/nginx.conf
RUN rm -rf /var/www && ln -sf /opt/app/client/public/ /var/www
USER app

ARG BUILD_INFO="docker-development"
ENV BUILD_INFO=${BUILD_INFO}

ENV FRONTEND_PORT=${FRONTEND_PORT:-8080}
EXPOSE ${FRONTEND_PORT}

ENV BACKEND_HOST=${BACKEND_HOST:-"server"}
ENV BACKEND_PORT=${BACKEND_PORT:-6666}
ENV BASE_URL=${BASE_URL:-/}

CMD ["/opt/app/client/docker-start-dev.sh"]
VOLUME ["/data"]


### RELEASE ###
FROM alpine:latest AS release

ARG PUID=1000
ARG PGID=1000

RUN mkdir -p /opt/app/client
WORKDIR /opt/app/client

# Add release dependencies
RUN apk add --no-cache --update dumb-init \
    nginx
RUN addgroup -g ${PGID} app \
    && adduser -SDH -h /opt/app -g '' -G app -u ${PUID} app \
    && chown -R app:app /opt/app /var/log/nginx /var/lib/nginx /etc/nginx
USER app

COPY --chown=app docker-start.sh ./
COPY --chown=app nginx.conf.docker ./nginx.conf
COPY --chown=app --from=builder /opt/app/client/public/ ./public

USER root
RUN ln -sf /opt/app/client/nginx.conf.docker /etc/nginx/nginx.conf
RUN rm -rf /var/www && ln -sf /opt/app/client/public/ /var/www
USER app

ENV FRONTEND_PORT=${FRONTEND_PORT:-8080}
EXPOSE ${FRONTEND_PORT}

ENV BACKEND_HOST=${BACKEND_HOST:-127.0.0.1}
ENV BACKEND_PORT=${BACKEND_PORT:-6666}
ENV BASE_URL=${BASE_URL:-/}

CMD ["/opt/app/client/docker-start.sh"]
VOLUME ["/data"]

ARG DOCKER_REPO
ARG BUILD_DATE
ARG SOURCE_COMMIT
LABEL \
    maintainer="" \
    org.opencontainers.image.title="${DOCKER_REPO}" \
    org.opencontainers.image.url="https://github.com/rr-/szurubooru" \
    org.opencontainers.image.documentation="https://github.com/rr-/szurubooru/blob/${SOURCE_COMMIT}/doc/INSTALL.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.source="https://github.com/rr-/szurubooru" \
    org.opencontainers.image.revision="${SOURCE_COMMIT}" \
    org.opencontainers.image.licenses="GPL-3.0"
