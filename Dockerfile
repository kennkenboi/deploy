FROM alpine:latest

MAINTAINER Kenboi <kennkenboi+docker@gmail.com>

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache dos2unix openssh-client \
	&& rm -rf /var/cache/apk/*

ENV DEPLOY_HOST=80.240.17.13
ENV DEPLOY_USER=root
ENV DEPLOY_PATH=/var/www/html/testai-api

COPY entrypoint.sh /script/entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/bin/sh", "/script/entrypoint.sh"]

CMD ["deploy"]
