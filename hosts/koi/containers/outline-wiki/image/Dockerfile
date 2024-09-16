FROM outlinewiki/outline-enterprise:0.79.1

USER root
RUN apt-get update && apt-get install -y patch
USER nodejs

COPY license.patch /license.patch
RUN patch /opt/outline/build/server/utils/LicenseHelper.js < /license.patch