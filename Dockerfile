FROM node:8.9.0-alpine
LABEL maintainer="https://github.com/verdaccio/verdaccio"

RUN apk --no-cache add openssl && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/bin/dumb-init

ENV APPDIR /usr/local/app

WORKDIR $APPDIR

ADD ./verdaccio $APPDIR

ENV NODE_ENV=production

RUN npm config set registry http://registry.npmjs.org/ && \
    npm install -g -s --no-progress yarn@0.28.4 --pure-lockfile && \
    yarn install --production=false && \
    yarn run build:webui && \
    yarn cache clean && \
    yarn install --production=true --pure-lockfile

RUN mkdir -p /verdaccio/storage /verdaccio/conf

# use our upm config
ADD conf/upm-proxy.yaml /verdaccio/conf/config.yaml
ADD conf/openssl.conf /verdaccio/conf/openssl.conf

# create the ssl cert
RUN openssl req -x509 -nodes -days %days% -newkey rsa:2048 -keyout /verdaccio/conf/server.pem -out /verdaccio/conf/server.pem -config /verdaccio/conf/openssl.conf && \
    openssl pkcs12 -export -out /verdaccio/conf/server.pfx -in /verdaccio/conf/server.pem -passout pass:

# done with openssl now
RUN apk del openssl

# run on 443
ENV PORT 443
ENV PROTOCOL https

EXPOSE $PORT

VOLUME ["/verdaccio"]

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

CMD $APPDIR/bin/verdaccio --config /verdaccio/conf/config.yaml --listen $PROTOCOL://0.0.0.0:${PORT}
