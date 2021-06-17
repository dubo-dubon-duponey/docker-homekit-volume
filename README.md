# What

Docker image to control the volume of your raspberries.

This is based on [HomeKit Alsa](https://github.com/dubo-dubon-duponey/homekit-alsa).

## Image features

* multi-architecture:
  * [x] linux/amd64
  * [x] linux/386
  * [x] linux/arm64
  * [x] linux/arm/v7
  * [x] linux/arm/v6
  * [ ] linux/ppc64
  * [ ] linux/s390x
* hardened:
  * [x] image runs read-only
  * [x] image runs with no capabilities (unless you want it on port 443)
  * [x] process runs as a non-root user, disabled login, no shell
* lightweight
  * [x] based on our slim [Debian bullseye version (2021-06-01)](https://github.com/dubo-dubon-duponey/docker-debian)
  * [x] simple entrypoint script
  * [ ] multi-stage build with ~~no installed~~ dependencies for the runtime image:
    * alsa-utils
* observable
  * [x] healthcheck
  * [x] log to stdout
  * [ ] ~~prometheus endpoint~~

 * unsupported / not enabled:
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
    dubodubonduponey/homekit-alsa
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
