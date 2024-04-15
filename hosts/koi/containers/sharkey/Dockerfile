FROM registry.activitypub.software/transfem-org/sharkey:develop@sha256:5ba2bd0792e38f830b0d624e9327bd0419de597f604af74eb895d64ccfdf86b4

COPY patches /patches

USER root
RUN apk add patch 
USER sharkey

RUN patch -p0 < /patches/zond.patch && \
    patch -p0 < /patches/software.patch && \
    patch -p0 < /patches/stats.patch && \
    cp -f /patches/robots.txt /sharkey/packages/backend/assets/robots.txt && \
    node /patches/patch-locale.js
