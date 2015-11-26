FROM alpine
MAINTAINER Demetrius Johnson "contact@demetriusj.com"

LABEL Description="VEVO's base slimmed down version of nodejs" Vendor="VEVO" Version="1.0"

# To customize your docker
ENV NODE_VERSION=5.1.0 \
  NPM_CONFIG_LOGLEVEL=info \
  NPM_VERSION=3 \
  CONFIG_FLAGS="--fully-static" \
  EXCLUDE_PKG="curl make gcc g++ python linux-headers paxctl libgcc libstdc++ gpgme"

RUN apk add --update curl make gcc g++ python linux-headers paxctl libgcc libstdc++ gpgme   && \
  set -ex                                                                                   && \
  for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done                                                                                      && \
  cd /tmp                                                                                   && \
  curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz"             && \
  curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"                     && \
  gpg --verify SHASUMS256.txt.asc                                                           && \
  grep " node-v${NODE_VERSION}.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -                && \
  tar -xzf "node-v${NODE_VERSION}.tar.gz"                                                   && \
  cd node-v${NODE_VERSION}                                                                  && \
  ./configure --prefix=/usr ${CONFIG_FLAGS}                                                 && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)                               && \
  make install                                                                              && \
  paxctl -cm /usr/bin/node                                                                  && \
  apk del --purge ${EXCLUDE_PKG}                                                            && \
  rm -rf /etc/ssl \
    /usr/include \
    /usr/share/man \
    /tmp/* \
    /var/cache/apk/* \
    /root/.npm \
    /root/.node-gyp \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html

RUN adduser -D node
ENV HOME /home/node
USER node

CMD [ "node" ]

