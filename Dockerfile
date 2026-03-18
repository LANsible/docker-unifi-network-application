FROM amazoncorretto:21.0.10-alpine@sha256:c64034bdceaff59b33bc366b9ab1b7fc5593d8155daf82cd978541b206555d1f
# renovate: datasource=docker depName=unifi-network-application packageName=linuxserver/unifi-network-application
ENV UNIFI_VERSION=10.1.89

RUN wget -qO- dl.ui.com/unifi/$UNIFI_VERSION/UniFi.unix.zip | unzip - && \
    mv /UniFi /usr/lib/unifi && \
    chown -R 1000:1000 /usr/lib/unifi && \
    apk add --no-cache openssl envsubst

# TODO make this more elegant with -Xlog parameter
# or -Dunifi.logdir which seems ignored
RUN mkdir /logs && \
    ln -sf /dev/stdout /logs/hotspot.log && \
    ln -sf /dev/stdout /logs/inform_request.log && \
    ln -sf /dev/stdout /logs/migration.log && \
    ln -sf /dev/stdout /logs/server.log && \
    ln -sf /dev/stdout /logs/startup.log && \
    ln -sf /dev/stdout /logs/state.log && \
    ln -sf /dev/stdout /logs/tasks.log && \
    ln -sf /data /usr/lib/unifi/data

COPY entrypoint.sh /entrypoint.sh
COPY --chown=1000:1000 system.properties /usr/lib/unifi/system.properties.tpl

USER 1000
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "java", \
    "-XX:+UseParallelGC", \
    "-Dfile.encoding=UTF-8", \
    "-Djava.awt.headless=true", \
    "-Dapple.awt.UIElement=true", \
    "-Dunifi.core.enabled=false", \
    "-XX:+ExitOnOutOfMemoryError", \
    "-XX:+CrashOnOutOfMemoryError", \
    "--add-opens=java.base/java.lang=ALL-UNNAMED", \
    "--add-opens=java.base/java.time=ALL-UNNAMED", \
    "--add-opens=java.base/sun.security.util=ALL-UNNAMED", \
    "--add-opens=java.base/java.io=ALL-UNNAMED", \
    "--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED", \
    "-jar", "/usr/lib/unifi/lib/ace.jar", "start" \
]
