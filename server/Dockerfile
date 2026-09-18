ARG ALPINE_VERSION=3.22

### Pre-build ###
FROM alpine:$ALPINE_VERSION AS prereqs

RUN mkdir -p /opt/app/server
WORKDIR /opt/app/server

RUN apk --no-cache add \
        python3 \
        python3-dev \
        py3-pip \
        build-base \
        libheif \
        libheif-dev \
        libavif \
        libavif-dev \
        ffmpeg \
        # from requirements.txt: \
        py3-yaml \
        py3-psycopg2 \
        py3-sqlalchemy \
        py3-certifi \
        py3-numpy \
        py3-pillow \
        py3-pynacl \
        py3-tz \
        py3-pyrfc3339
RUN pip3 install --no-cache-dir --disable-pip-version-check --break-system-packages \
        "alembic>=0.8.5" \
        "coloredlogs==5.0" \
        yt-dlp \
        # pillow-heif v1.5.0 breaks linux/arm/v7 support
        "pillow-heif>=1.0.0,<1.5.0" \
        "pillow-avif-plugin>=1.4.6"
RUN apk --no-cache del py3-pip

COPY --chown=app:app . ./
RUN rm -rf ./szurubooru/tests

ARG PUID=1000
ARG PGID=1000

RUN addgroup -g ${PGID} app \
    && adduser -SDH -h /opt/app -g '' -G app -u ${PUID} app \
    && chown -R app:app /opt/app

### testing ###
FROM --platform=$BUILDPLATFORM prereqs AS testing
WORKDIR /opt/app/server

RUN apk --no-cache add \
        py3-pip \
        py3-pytest \
        py3-pytest-cov \
        postgresql \
 && pip3 install --no-cache-dir --disable-pip-version-check --break-system-packages \
        pytest-pgsql \
        pytest-xdist \
        freezegun \
 && apk --no-cache del py3-pip

COPY --chown=app:app ./szurubooru/tests ./szurubooru/tests/

ENV TEST_ENVIRONMENT="true"
USER app
ENTRYPOINT ["pytest", "--tb=short"]
CMD ["szurubooru/"]

### Development ###
FROM prereqs AS development
WORKDIR /opt/app/server

USER root
RUN mkdir -p /data && chown -R app:app /data
RUN apk --no-cache add \
    dumb-init \
    py3-pip \
    py3-setuptools \
    py3-waitress \
    && pip3 install --no-cache-dir --disable-pip-version-check --break-system-packages \
    hupper
USER app

ENV BACKEND_PORT=${BACKEND_PORT:-6666}
EXPOSE ${BACKEND_PORT}

ENV THREADS_WAITRESS=${THREADS:-4}

CMD ["/opt/app/server/docker-start-dev.sh"]
VOLUME ["/data/"]


### release ###
FROM prereqs AS release

WORKDIR /opt/app/server

USER root
RUN mkdir -p /data && chown -R app:app /data
RUN apk --no-cache add \
        dumb-init \
        py3-setuptools \
        py3-waitress

USER app
CMD ["/opt/app/server/docker-start.sh"]

ENV BACKEND_PORT=${BACKEND_PORT:-6666}
EXPOSE ${BACKEND_PORT}

ENV THREADS_WAITRESS=${THREADS:-4}

VOLUME ["/data/"]

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
