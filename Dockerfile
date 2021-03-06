# Dockerfile for https://github.com/adnanh/webhook

FROM        golang:1.8.3-alpine3.6 as builder

ENV         GOPATH /go
ENV         SRCPATH ${GOPATH}/src/github.com/adnanh
ENV         WEBHOOK_VERSION 2.6.4

RUN         apk add --update git build-base; \
            go get -u -v github.com/adnanh/webhook; \
	    mkdir -p /go/bin; \
	    cd $GOPATH/src/github.com/adnanh/webhook; \
	    go build -ldflags="-s -w" -v -o /go/bin/webhook

FROM        alpine:3.6
RUN         apk --no-cache add ca-certificates; \
	    mkdir -p /webhook/hooks
WORKDIR     /webhook
COPY        --from=builder /go/bin/webhook .

VOLUME      /webhook/hooks
EXPOSE      9000

ENTRYPOINT  ["/webhook/webhook"]
