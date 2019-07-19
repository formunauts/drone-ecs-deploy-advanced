FROM alpine:3.9

RUN apk add --update --no-cache \
    curl \
    jq \
    ca-certificates \
    bash \
    python \
    && python -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip install --upgrade pip setuptools \
    awscli --ignore-installed \
    && rm -r /root/.cache

COPY update.sh /bin/
COPY ecs-deploy /bin/

ENTRYPOINT ["/bin/bash"]

CMD ["/bin/update.sh"]
