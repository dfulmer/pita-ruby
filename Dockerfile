ARG RUBY_VERSION=3.2
FROM ruby:${RUBY_VERSION}

ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="dfulmer@umich.edu"

RUN gem install bundler

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app

CMD ["tail", "-f", "/dev/null"]
