FROM ruby:3.0.0-alpine

ENV RUNTIME_PACKAGES="linux-headers build-base libxml2-dev libxslt-dev make gcc libc-dev nodejs yarn tzdata g++ postgresql-dev postgresql git openssl" \
    CHROME_PACKAGES="chromium-chromedriver zlib-dev chromium xvfb wait4ports xorg-server dbus ttf-freefont mesa-dri-swrast udev" \
    DELETE_PACKAGES="build-packages libxml2-dev curl-dev make gcc libc-dev g++" \
    BUILD_PACKAGES="build-base curl-dev" \
    APP_ROOT="/myapp" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --no-cache ${CHROME_PACKAGES} && \
    apk add --virtual build-packages --no-cache ${BUILD_PACKAGES} && \
    gem install rails -v '6.1.1' && \
    gem install bundler

WORKDIR /tmp
COPY Gemfile* ./
COPY package.json ./
COPY yarn.lock ./

RUN bundle install && \
    yarn install && \
    rails assets:precompile && \
    bundle clean --force && \
    apk del ${DELETE_PACKAGES} build-packages && \
    rm -rf /usr/local/share/.cache/* /var/cache/* /tmp/*

WORKDIR $APP_ROOT
COPY . ${APP_ROOT}/

ADD ./docker/init/db/setup.sql /docker-entrypoint-initdb.d/
RUN chown postgres:postgres /docker-entrypoint-initdb.d/setup.sql

CMD ["rails", "server", "-b", "0.0.0.0"]
