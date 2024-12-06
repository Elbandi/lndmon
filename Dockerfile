# If you change this value, please change it in the following files as well:
# /Dockerfile
# /tools/Dockerfile
# /.github/workflows/main.yml
FROM golang:1.21.6-alpine as builder

# Install build dependencies such as git and glide.
RUN apk add --no-cache git gcc musl-dev

RUN apk add --no-cache --update alpine-sdk \
    git \
    make \
    bash \
    gcc

ENV GO111MODULE on
COPY . /go/src/github.com/lightninglabs/lndmon/
RUN cd /go/src/github.com/lightninglabs/lndmon/cmd/lndmon && go build

# Start a new image
FROM alpine:3.21@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45 as final

# renovate: datasource=repology depName=alpine_3_20/bash versioning=loose
ARG BASH_VERSION="5.2.26-r0"

# renovate: datasource=repology depName=alpine_3_20/busybox versioning=loose
ARG BUSYBOX_VERSION="1.36.1-r29"

# renovate: datasource=repology depName=alpine_3_20/iputils versioning=loose
ARG IPUTILS_VERSION="20240117-r0"

COPY --from=builder /go/src/github.com/lightninglabs/lndmon/cmd/lndmon/lndmon /bin/

# Add bash, for quality of life and SSL-related reasons.
RUN apk --no-cache add \
    bash=${BASH_VERSION} \
    busybox=${BUSYBOX_VERSION} \
    iputils=${IPUTILS_VERSION}

ENTRYPOINT ["/bin/lndmon"]
