FROM alpine:stable

RUN apk add --no-cache imapsync && \
    apk cache clean && \
    useradd -r -d /data syncer

VOLUME /data

WORKDIR /data

USER /data
    
