ARG           FROM_IMAGE_BUILDER=ghcr.io/dubo-dubon-duponey/base:builder-bullseye-2021-06-01@sha256:f0ba079c698161922961d9492e27469fca807b9a86a68e6162c325b62b792e81
ARG           FROM_IMAGE_RUNTIME=ghcr.io/dubo-dubon-duponey/base:runtime-bullseye-2021-06-01@sha256:d904e13fbfd217ced9a853d932281f2f64e108d725a767858d2c1957b4e10232

#######################
# Extra builder for healthchecker
#######################
FROM          --platform=$BUILDPLATFORM $FROM_IMAGE_BUILDER                                                             AS builder-healthcheck

ARG           GIT_REPO=github.com/dubo-dubon-duponey/healthcheckers
ARG           GIT_VERSION=51ebf8c
ARG           GIT_COMMIT=51ebf8ca3d255e0c846307bf72740f731e6210c3
ARG           GO_BUILD_SOURCE=./cmd/http
ARG           GO_BUILD_OUTPUT=http-health
ARG           GO_LD_FLAGS="-s -w"
ARG           GO_TAGS="netgo osusergo"

WORKDIR       $GOPATH/src/$GIT_REPO
RUN           git clone --recurse-submodules git://"$GIT_REPO" . && git checkout "$GIT_COMMIT"
ARG           GOOS="$TARGETOS"
ARG           GOARCH="$TARGETARCH"

# hadolint ignore=SC2046
RUN           env GOARM="$(printf "%s" "$TARGETVARIANT" | tr -d v)" go build -trimpath $(if [ "$CGO_ENABLED" = 1 ]; then printf "%s" "-buildmode pie"; fi) \
                -ldflags "$GO_LD_FLAGS" -tags "$GO_TAGS" -o /dist/boot/bin/"$GO_BUILD_OUTPUT" "$GO_BUILD_SOURCE"

##########################
# Builder custom
# Custom steps required to build this specific image
##########################
FROM          --platform=$BUILDPLATFORM $FROM_IMAGE_BUILDER                                                             AS builder

ARG           GIT_REPO=github.com/dubo-dubon-duponey/homekit-alsa
ARG           GIT_VERSION=6320344
ARG           GIT_COMMIT=6320344bf748e1fb335a577177bb9115c12fa4ab
ARG           GO_BUILD_SOURCE=./cmd/homekit-alsa
ARG           GO_BUILD_OUTPUT=homekit-alsa
ARG           GO_LD_FLAGS="-s -w"
ARG           GO_TAGS="netgo osusergo"

WORKDIR       $GOPATH/src/$GIT_REPO
RUN           git clone --recurse-submodules git://"$GIT_REPO" . && git checkout "$GIT_COMMIT"
ARG           GOOS="$TARGETOS"
ARG           GOARCH="$TARGETARCH"

# hadolint ignore=SC2046
RUN           env D="$TARGETPLATFORM" GOARM="$(printf "%s" "$TARGETVARIANT" | tr -d v)" go build -trimpath $(if [ "$CGO_ENABLED" = 1 ]; then printf "%s" "-buildmode pie"; fi) \
                -ldflags "$GO_LD_FLAGS" -tags "$GO_TAGS" -o /dist/boot/bin/"$GO_BUILD_OUTPUT" "$GO_BUILD_SOURCE"

COPY          --from=builder-healthcheck /dist/boot/bin           /dist/boot/bin
RUN           chmod 555 /dist/boot/bin/*

#######################
# Running image
#######################
FROM          $FROM_IMAGE_RUNTIME

USER          root

RUN           --mount=type=secret,mode=0444,id=CA,dst=/etc/ssl/certs/ca-certificates.crt \
              --mount=type=secret,id=CERTIFICATE \
              --mount=type=secret,id=KEY \
              --mount=type=secret,id=PASSPHRASE \
              --mount=type=secret,mode=0444,id=GPG.gpg \
              --mount=type=secret,id=NETRC \
              --mount=type=secret,id=APT_SOURCES \
              --mount=type=secret,id=APT_OPTIONS,dst=/etc/apt/apt.conf.d/dbdbdp.conf \
              apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                alsa-utils=1.2.4-1        && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

USER          dubo-dubon-duponey

# Get relevant bits from builder
COPY          --from=builder --chown=$BUILD_UID:root /dist /

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

HEALTHCHECK   --interval=120s --timeout=30s --start-period=10s --retries=1 CMD http-health || exit 1
