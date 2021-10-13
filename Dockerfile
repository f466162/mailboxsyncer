FROM alpine

ADD sync.sh /sync.sh

RUN apk add --no-cache imapsync bash && \
    chmod +x /sync.sh && \
    adduser --uid 999 --home /data --no-create-home --system syncer

VOLUME /data

WORKDIR /data

USER syncer

ENTRYPOINT [ "/usr/bin/tail", "-f", "/dev/null" ]
