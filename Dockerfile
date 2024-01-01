FROM golang:1.21-alpine as builder
WORKDIR /wd
COPY go.mod go.sum main.go .
RUN go mod download
COPY modules modules
RUN go build -o caddy .

from alpine:latest

RUN apk add --no-cache \
	ca-certificates \
	libcap \
	mailcap

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

copy --from=builder /wd/caddy /usr/local/bin/caddy

copy docker/Caddyfile /etc/caddy/Caddyfile
copy docker/archive.zip /data/archive.zip

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
