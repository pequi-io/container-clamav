# container-clamav

Containerized ClamAV open source antivirus.

## Usage

You can available container images in [https://github.com/surt-io/container-clamav/pkgs/container/container-clamav](https://github.com/surt-io/container-clamav/pkgs/container/container-clamav)

### Docker

```bash
docker run -d -p 3310:3310 --name clamav ghcr.io/surt-io/container-clamav
```

### Kubernetes

```bash
kubectl apply -f https://github.com/surt-io/container-clamav/examples/kubernetes
```

## Surt Integration

ClamAV is running as `daemon` where `clamd` is exposed using TCP on the port `3310`. In backgroup, `freshclam` is checking and updating the virus signature database.

**Surt** uses `container-clamav` container image as its default antivirus engine solution. However, you can use this container image as you wish.

## Base image

`container-clamav` container image is based on [Alpine Linux](https://alpinelinux.org/about/).

## Image with Initialized Databases

After every new release of `container-clamav` image, we also create a second image with the tag suffix `-initdb` with initialized ClamAV virus database (.cvd) to avoid [issues with rate limiting](https://www.mail-archive.com/clamav-users@lists.clamav.net/msg50481.html) and/or longer initialization time (freshclam takes a few minutes to update the database signatures).

```bash
docker run -d -p 3310:3310 --name clamav-initdb ghcr.io/surt-io/container-clamav:latest-initdb
```

## Environment Variables

You can set environment variables to control the behavior of the `clamd` and `freshclam` services. For more information, please check [Clamav: Controlling the container](https://docs.clamav.net/manual/Installing/Docker.html#controlling-the-container)

### Docker Environment Variables

The following example shows how to change `clamd` startup timeout to 300 seconds (default: 1800)

```bash
docker run -d -p 3310:3310 --name clamav \
    --env 'CLAMD_STARTUP_TIMEOUT=300' \
    ghcr.io/surt-io/container-clamav
```

### Kubernetes Environment Variables

The following example shows how to increase some max settings for `clamd` services using `env` spec:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: clamav
  name: clamav
spec:
  replicas: 1
  selector:
    matchLabels:
      app: clamav
  template:
    metadata:
      labels:
        app: clamav
    spec:
      containers:
      - name: clamav
        image: mkodockx/docker-clamav:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3310
          protocol: TCP
        env:
          - name: CLAMD_CONF_MaxFileSize
            value: "1000M"
          - name: CLAMD_CONF_StreamMaxLength
            value: "1000M"
          - name: CLAMD_CONF_MaxScanSize
            value: "1000M"
```

## Persisting the virus database

The virus database in `/var/lib/clamav` is by default unique to each container and thus is normally not shared. Howerver, if you want to persist it across short-lived ClamAV container, please check some examples below. For more information, please check [Clamav: Persisting the virus database (volume)](https://docs.clamav.net/manual/Installing/Docker.html#persisting-the-virus-database-volume)

### Using Docker Volumes

You can create a persistent volume, and then mount this volume to your container:

```bash
# create `clam_db` volume
docker volume create clam_db

# run container and mount `clam_db` volume using `/var/lib/clamav` as target.
docker run -d -p 3310:3310 --name clamav \
    --mount source=clam_db,target=/var/lib/clamav \
    ghcr.io/surt-io/container-clamav

```

### Using Kubernetes Persistent Volumes

You can use PersistentVolume subsystem for managing storage in Kubernetes. For more information, please check [Kubernetes - Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
