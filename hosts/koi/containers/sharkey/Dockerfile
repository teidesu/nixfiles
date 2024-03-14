FROM registry.activitypub.software/transfem-org/sharkey:develop@sha256:fd6c17901d7103d38837e6415b4e34fbf641e82961a6ec9d7e9c249f4779cf4e

COPY patches /patches

USER root
RUN apk add patch 
USER sharkey

RUN patch -p0 < /patches/zond.patch && \
    patch -p0 < /patches/software.patch && \
    patch -p0 < /patches/stats.patch && \
    node /patches/patch-locale.js
