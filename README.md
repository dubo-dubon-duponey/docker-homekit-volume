# What

Docker image to expose a Homekit accessory controlling the volume of a host running Alsa - typically a raspberry pie.

This is based on [HomeKit Alsa](https://github.com/dubo-dubon-duponey/homekit-alsa).

## Image features

* multi-architecture:
  * [x] linux/amd64
  * [x] linux/arm64
  * [x] linux/arm/v7
  * [x] linux/arm/v6
* hardened:
  * [x] image runs read-only
  * [x] image runs with no capabilities (unless you want it on a privileged port, in which case you need to grant NET_BIND_SERVICE)
  * [x] process runs as a non-root user, disabled login, no shell
  * [x] binaries are compiled with PIE, bind now, stack protection, fortify source and read-only relocations (additionally stack clash protection on amd64)
* lightweight
  * [x] based on our slim [Debian bullseye version](https://github.com/dubo-dubon-duponey/docker-debian)
  * [x] simple entrypoint script
  * [x] multi-stage build with no installed dependencies for the runtime image
* observable
  * [x] healthcheck
  * [x] log to stdout
  * [ ] ~~prometheus endpoint~~

* unsupported / not enabled:
  * [ ] linux/386: probably builds, disabled by default
  * [ ] linux/ppc64: alsa SwParams does not build
  * [ ] linux/s390x: alsa SwParams does not build

## Run

```bash
docker run -d --rm \
    --name "speaker" \
    --env HOMEKIT_NAME="My Fancy Speaker" \
    --env HOMEKIT_PIN="87654312" \
    --volume /data \
    --group-add audio \
    --device /dev/snd \
    --net host \
    --cap-drop ALL \
    --read-only \
    dubodubonduponey/homekit-volume
```

## Notes

### Networking

You need to run this in `host` or `mac(or ip)vlan` networking (because of mDNS).

### Additional arguments

Any additional arguments when running the image will get fed to the `homekit-alsa` binary.

Try `--help` for more.

### Custom configuration

All configuration is done through environment variables, specifically:

```dockerfile
ENV           ALSA_CARD=""
ENV           ALSA_DEVICE=""

ENV           HOMEKIT_NAME="Speak-easy"
ENV           HOMEKIT_PIN="87654312"
ENV           HOMEKIT_MANUFACTURER="DuboDubonDuponey"
ENV           HOMEKIT_SERIAL=""
ENV           HOMEKIT_MODEL="Acme"
ENV           HOMEKIT_VERSION="0"
```

## Moar?

See [DEVELOP.md](DEVELOP.md)
