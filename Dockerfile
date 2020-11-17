ARG           BUILDER_BASE=dubodubonduponey/base:builder
ARG           RUNTIME_BASE=dubodubonduponey/base:runtime

#######################
# Extra builder for healthchecker
#######################
# hadolint ignore=DL3006,DL3029
FROM          --platform=$BUILDPLATFORM $BUILDER_BASE                                                                   AS builder-healthcheck

ARG           GIT_REPO=github.com/dubo-dubon-duponey/healthcheckers
ARG           GIT_VERSION=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/$GIT_REPO
RUN           git clone git://$GIT_REPO .
RUN           git checkout $GIT_VERSION
# hadolint ignore=DL4006
RUN           env GOOS=linux GOARCH="$(printf "%s" "$TARGETPLATFORM" | sed -E 's/^[^/]+\/([^/]+).*/\1/')" go build -v -ldflags "-s -w" \
                -o /dist/boot/bin/http-health ./cmd/http

##########################
# Builder custom
# Custom steps required to build this specific image
##########################
# hadolint ignore=DL3006,DL3029
FROM          --platform=$BUILDPLATFORM $BUILDER_BASE                                                                   AS builder

ARG           GIT_REPO=github.com/dubo-dubon-duponey/homekit-alsa
ARG           GIT_VERSION=6320344bf748e1fb335a577177bb9115c12fa4ab

WORKDIR       $GOPATH/src/$GIT_REPO
RUN           git clone git://$GIT_REPO .
RUN           git checkout $GIT_VERSION

# hadolint ignore=DL4006
RUN           env GOOS=linux GOARCH="$(printf "%s" "$TARGETPLATFORM" | sed -E 's/^[^/]+\/([^/]+).*/\1/')" go build -v -ldflags "-s -w" \
                -o /dist/boot/bin/homekit-alsa ./cmd/homekit-alsa/main.go

COPY          --from=builder-healthcheck /dist/boot/bin           /dist/boot/bin
RUN           chmod 555 /dist/boot/bin/*

#######################
# Running image
#######################
# hadolint ignore=DL3006
FROM          $RUNTIME_BASE

USER          root

RUN           apt-get update -qq          && \
              apt-get install -qq --no-install-recommends \
                alsa-utils=1.1.8-2        && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

USER          dubo-dubon-duponey

# Get relevant bits from builder
COPY          --from=builder --chown=$BUILD_UID:root /dist .

ENV           ALSA_CARD=""
ENV           ALSA_DEVICE=""

ENV           HOMEKIT_NAME="Speak-easy"
ENV           HOMEKIT_PIN="87654312"
ENV           HOMEKIT_MANUFACTURER="DuboDubonDuponey"
ENV           HOMEKIT_SERIAL=""
ENV           HOMEKIT_MODEL="Acme"
ENV           HOMEKIT_VERSION="0"

ENV           PORT="10042"

ENV           HEALTHCHECK_URL=http://127.0.0.1:$PORT/accessories

EXPOSE        $PORT/tcp

# Default volume for data
VOLUME        /data

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=1 CMD http-health || exit 1
