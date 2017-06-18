# Dockerfile for https://github.com/adnanh/webhook

FROM        golang:1.8.3-alpine3.6 as builder

ENV         GOPATH /go
ENV         SRCPATH ${GOPATH}/src/github.com/adnanh
ENV         WEBHOOK_VERSION 2.6.4

RUN         apk add --update -t build-deps build-base curl go git libc-dev gcc libgcc && \
            git config --global http.https://gopkg.in.followRedirects true && \
            curl -L -o /tmp/webhook-${WEBHOOK_VERSION}.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            mkdir -p ${SRCPATH} && tar -xvzf /tmp/webhook-${WEBHOOK_VERSION}.tar.gz -C ${SRCPATH} && \
            mv -f ${SRCPATH}/webhook-* ${SRCPATH}/webhook && \
            cd ${SRCPATH}/webhook && go get -d && go build -ldflags="-s -w" -v -o /go/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf ${GOPATH}

FROM alpine:3.6
RUN apk --no-cache add ca-certificates \
	&& mkdir -p /webhook
WORKDIR /webhook
COPY --from=builder /go/bin/webhook .

EXPOSE 9000

ENTRYPOINT ["/webhook/webhook"]
