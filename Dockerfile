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
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o dist/homekit-alsa ./cmd/homekit-alsa/main.go

COPY          http-client.go cmd/http-client/http-client.go
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o dist/http-client ./cmd/http-client

WORKDIR       /dist/bin
RUN           cp "$GOPATH"/src/github.com/dubo-dubon-duponey/homekit-alsa/dist/homekit-alsa     .
RUN           cp "$GOPATH"/src/github.com/dubo-dubon-duponey/homekit-alsa/dist/http-client      .
RUN           chmod 555 ./*

#######################
# Running image
#######################
FROM          dubodubonduponey/base:runtime

USER          root

ARG           DEBIAN_FRONTEND="noninteractive"
ENV           TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN           apt-get update              > /dev/null && \
              apt-get install -y --no-install-recommends \
                alsa-utils=1.1.8-2          > /dev/null && \
              apt-get -y autoremove       > /dev/null && \
              apt-get -y clean            && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

USER          dubo-dubon-duponey

# Get relevant bits from builder
COPY          --from=builder --chown=$BUILD_UID:0 /dist .

ENV           ALSA_CARD=""
ENV           ALSA_DEVICE=""

ENV           HOMEKIT_NAME="Speak-easy"
ENV           HOMEKIT_PIN="87654312"
ENV           HOMEKIT_MANUFACTURER="DuboDubonDuponey"
ENV           HOMEKIT_SERIAL=""
ENV           HOMEKIT_MODEL="Acme"
ENV           HOMEKIT_VERSION="0"

ENV           PORT="12345"

ENV           HEALTHCHECK_URL=http://127.0.0.1:$PORT/accessories

EXPOSE        $PORT/tcp

# Default volume for data
VOLUME        /data

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=1 CMD http-client || exit 1
