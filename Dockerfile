ARG GO_BASE_IMAGE=golang:1.16-alpine3.13

# Build https://github.com/mozilla/sops
FROM $GO_BASE_IMAGE AS sops_builder
ARG SOPS_VERSION=3.7.1
RUN apk --no-cache add make && \
    wget -qO- https://github.com/mozilla/sops/archive/refs/tags/v$SOPS_VERSION.tar.gz | tar xzf - && \
    cd sops-$SOPS_VERSION && \
    CGO_ENABLED=1 make install && \
    cd .. && \
    rm -rf sops-$SOPS_VERSION

# Build https://github.com/jmagnusson/gke-kubeconfig
FROM $GO_BASE_IMAGE AS gke_kubeconfig_builder
ARG GKE_KUBECONFIG_VERSION=0.1
RUN apk --no-cache add make && \
    wget -qO- https://github.com/jmagnusson/gke-kubeconfig/archive/refs/tags/v$GKE_KUBECONFIG_VERSION.tar.gz | tar xzf - && \
    cd gke-kubeconfig-$GKE_KUBECONFIG_VERSION && \
    ls -ahl && \
    go install && \
    cd .. && \
    rm -rf gke-kubeconfig-$GKE_KUBECONFIG_VERSION
RUN pwd && ls -ahl ./bin

# Main image
FROM alpine:3.13 AS action
RUN apk --no-cache add python3
COPY --from=sops_builder /go/bin/sops /usr/local/bin/
COPY --from=gke_kubeconfig_builder /go/bin/gke-kubeconfig /usr/local/bin/
COPY --from=alpine/helm:3.5.4 /usr/bin/helm /usr/local/bin/helm
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
