FROM --platform=linux/amd64 golang:1.25.7-alpine3.22 AS build

ARG NIKS3_VERSION=1.7.0

RUN apk add --no-cache git ca-certificates
RUN git clone --depth 1 --branch "v${NIKS3_VERSION}" https://github.com/Mic92/niks3.git /src

WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags='-s -w' -o /out/niks3-server ./cmd/niks3-server

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

COPY --from=build /out/niks3-server /usr/local/bin/niks3-server
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

EXPOSE 5751

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
