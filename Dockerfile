FROM debian

ENV LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" TZ="Europe/Amsterdam"

RUN \
  apt-get update -qq && \
  apt-get install -qy curl lame faad flac sox libio-socket-ssl-perl libnet-ssleay-perl && \
  apt-get clean -qy && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install LMS
RUN /bin/bash -c '\
  export DEBIAN_FRONTEND="noninteractive" && \
  OUT=$(curl -skL "http://downloads.slimdevices.com/nightly/index.php?ver=8.0") && \
  REGEX=".*href=\".(.*logitechmediaserver_8.0.0~[0-9]{4,}_amd64.deb)\"" && \
  if [[ ${OUT} =~ ${REGEX} ]]; then URL="http://downloads.slimdevices.com/nightly${BASH_REMATCH[1]}"; else exit 42; fi && \
  curl -skL -o /tmp/lms.deb $URL && \
  dpkg -i /tmp/lms.deb && \
  rm /tmp/lms.deb \
  '

RUN \
  mkdir /config /music /playlist && \
  chown 1028:100 /config /music /playlist

VOLUME /config /music /playlist
EXPOSE 3483 3483/udp 9000 9090

USER 1028:100
ENTRYPOINT ["squeezeboxserver"]
CMD ["--prefsdir", "/config/prefs", "--logdir", "/config/logs", "--cachedir", "/config/cache"]
