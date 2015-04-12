FROM ubuntu:trusty

MAINTAINER Travis Holton <travis@ideegeo.com>

RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

ENV KIBANA_VERSION 4.0.1-linux-x64

# Install Required Dependancies
RUN \
  apt-get -qq update && \
  apt-get -qy install supervisor \
                      curl \
                      openssh-server && \
  apt-get clean && \
  mkdir -p /var/run/sshd && \
  mkdir -p /opt/kibana && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Kibana and Configure Nginx

ADD https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz /opt
RUN \
  cd /opt/kibana && tar xzf /opt/kibana-$KIBANA_VERSION.tar.gz --strip-components=1 && \
  rm -f /opt/kibana-$KIBANA_VERSION.tar.gz

ADD supervisord.conf /etc/supervisor/conf.d/


WORKDIR /usr/local
ADD docker_start.sh /usr/local/
EXPOSE 22 

CMD ["./docker_start.sh"]
