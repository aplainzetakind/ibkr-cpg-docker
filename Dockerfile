FROM mcr.microsoft.com/playwright:v1.56.1-noble

ARG JAVA_VERSION=25

COPY get_portal.sh /root/

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-${JAVA_VERSION}-jdk \
    tini \
    unzip \
    cron && \
    apt-get clean && \
    /root/get_portal.sh && \
    rm -rf /root/get_portal.sh /var/lib/apt/lists/*

WORKDIR /pw

RUN npm init -y && \
    npm install playwright && \
    npx playwright install && \
    node -e "let pkg=require('./package.json'); pkg.type='module'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"

COPY conf.yaml /clientportal/root
COPY crontab /etc/cron.d/
COPY login.js /pw/
COPY entrypoint.sh /root/
COPY heartbeat.sh /root/
COPY login.sh /root/

RUN chmod 0644 /etc/cron.d/crontab && \
    chown root:root /etc/cron.d/crontab  \
    /root/entrypoint.sh  \
    /root/heartbeat.sh  \
    /root/login.sh && \
    crontab /etc/cron.d/crontab

ENTRYPOINT ["/usr/bin/tini", "--", "/root/entrypoint.sh"]
