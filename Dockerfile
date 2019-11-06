#######################
# Extra builder for healthchecker
#######################
FROM          --platform=$BUILDPLATFORM dubodubonduponey/base:builder                                                   AS builder-healthcheck

ARG           HEALTH_VER=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/healthcheckers
RUN           git clone git://github.com/dubo-dubon-duponey/healthcheckers .
RUN           git checkout $HEALTH_VER
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/bin/http-health ./cmd/http

RUN           chmod 555 /dist/bin/*

##########################
# Builder custom
# Custom steps required to build this specific image
##########################
FROM          --platform=$BUILDPLATFORM dubodubonduponey/base:builder                                   AS builder

ARG           DUBOAMP_VERSION="6f84f3e3244f8d2637e3b80db9a162b2f104e297"

WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/homekit-alsa
RUN           git clone https://github.com/dubo-dubon-duponey/homekit-alsa .
RUN           git checkout $DUBOAMP_VERSION

RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/bin/homekit-alsa ./cmd/homekit-alsa/main.go

RUN           chmod 555 /dist/bin/*

#######################
# Running image
#######################
FROM          dubodubonduponey/base:runtime

USER          root

ARG           DEBIAN_FRONTEND="noninteractive"
ENV           TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
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
COPY          --from=builder-healthcheck  /dist/bin/http-health ./bin/

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
