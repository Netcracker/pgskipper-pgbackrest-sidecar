FROM --platform=$BUILDPLATFORM golang:1.23.8-alpine3.21 AS builder

ENV GOSUMDB=off

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

# Copy the go source
COPY main/ main/
COPY pkg/ pkg/

RUN go mod tidy

# Build
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o ./build/_output/bin/pgskipper-pgbackrest-sidecar \
    -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} ./main/main.go

FROM alpine:3.21.3

ENV USER=postgres

RUN apk add --update busybox && \
    apk add --upgrade ssl_client && \
    apk add --upgrade curl pgbackrest

COPY --from=builder /workspace/build/_output/bin/pgskipper-pgbackrest-sidecar /usr/local/bin/pgskipper-pgbackrest-sidecar
COPY build/start.sh /opt/start.sh


RUN chgrp 0 /etc &&  \
    chmod g+w /etc && \
    chgrp 0 /etc/passwd &&  \
    chmod g+w /etc/passwd && \
    chmod 770 /var/lib/pgbackrest && \
    chmod 770 /var/log/pgbackrest && \
    chmod 770 /var/spool/pgbackrest && \
    chown postgres:0 /var/lib/pgbackrest && \
    chown postgres:0 /var/log/pgbackrest && \
    chown postgres:0 /var/spool/pgbackrest && \
    chmod 777 /opt/start.sh &&  \
    chmod +x /opt/start.sh

VOLUME /etc

CMD ["sh", "/opt/start.sh"]
USER ${USER}