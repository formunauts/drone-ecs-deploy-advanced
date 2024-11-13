FROM alpine:3.20

RUN apk add --update --no-cache \
    curl \
    jq \
    ca-certificates \
    bash \
    aws-cli \
    && apk add --update --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
    aws-session-manager-plugin

COPY update.sh /bin/
COPY ecs-deploy /bin/

ENTRYPOINT ["/bin/bash"]

CMD ["/bin/update.sh"]
