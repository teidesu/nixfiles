FROM registry.activitypub.software/transfem-org/sharkey:develop@sha256:42fcccd8248a77331b7b2a7a4a751f0f108c9e000890b33fb0745bb33c9358ad

COPY patches /patches

USER root
RUN apk add patch 
USER sharkey

RUN patch -p0 < /patches/zond.patch && \
    patch -p0 < /patches/software.patch && \
    patch -p0 < /patches/stats.patch && \
    cp -f /patches/robots.txt /sharkey/packages/backend/assets/robots.txt && \
    node /patches/patch-locale.js
