FROM alpine:3.20

RUN apk add --update --no-cache \
    curl \
    jq \
    ca-certificates \
    bash \
    aws-cli \
    && rm -rf /var/cache/apk/*

COPY update.sh /bin/
COPY ecs-deploy /bin/

ENTRYPOINT ["/bin/bash"]

CMD ["/bin/update.sh"]
