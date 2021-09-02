# container-clamav

Containerized ClamAV open source antivirus.

## Surt Integration

ClamAV is running as `daemon` where `clamd` is exposed using the tcp port `3310`. In backgroup, `freshclam` is checking and updating the virus signature database.

**Surt** uses `container-clamav` container image as its default antivirus engine solution. However, you can use this container image as you wish.

## Container Base image

`container-clamav` container image is based on [Alpine Linux](https://alpinelinux.org/about/).
