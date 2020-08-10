FROM adoptopenjdk/openjdk8:jdk8u262-b10-alpine
LABEL maintainer="surajn79@gmail.com"
STOPSIGNAL SIGKILL
ENV MIRROR https://www-eu.apache.org/dist/jmeter/binaries
ENV JMETER_VERSION 5.3
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN ${JMETER_HOME}/bin
ENV ALPN_VERSION 8.1.13.v20181017
ENV PATH ${JMETER_BIN}:$PATH
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && apk add --no-cache \
    curl \
    fontconfig \
    libxext \
    libxi \
    libxrender \
    libxtst \
    net-tools \
    shadow \
    su-exec \
    tcpdump  \
    ttf-dejavu \
 && cd /tmp/ \
 && curl --location --silent --show-error --output apache-jmeter-${JMETER_VERSION}.tgz ${MIRROR}/apache-jmeter-${JMETER_VERSION}.tgz \
 && curl --location --silent --show-error --output apache-jmeter-${JMETER_VERSION}.tgz.sha512 ${MIRROR}/apache-jmeter-${JMETER_VERSION}.tgz.sha512 \
 && sha512sum -c apache-jmeter-${JMETER_VERSION}.tgz.sha512 \
 && mkdir -p /opt/ \
 && tar x -z -f apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
 && rm -R -f apache* \
 && sed -i '/RUN_IN_DOCKER/s/^# //g' ${JMETER_BIN}/jmeter \
 && sed -i '/PrintGCDetails/s/^# /: "${/g' ${JMETER_BIN}/jmeter && sed -i '/PrintGCDetails/s/$/}"/g' ${JMETER_BIN}/jmeter \
 && chmod +x ${JMETER_HOME}/bin/*.sh \
 && jmeter --version \
 && curl --location --silent --show-error --output /opt/alpn-boot-${ALPN_VERSION}.jar https://repo1.maven.org/maven2/org/mortbay/jetty/alpn/alpn-boot/${ALPN_VERSION}/alpn-boot-${ALPN_VERSION}.jar \
 && rm -fr /tmp/*
# Required for HTTP2 plugins
ENV JVM_ARGS -Xbootclasspath/p:/opt/alpn-boot-${ALPN_VERSION}.jar
WORKDIR /jmeter
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["jmeter", "--?"]
