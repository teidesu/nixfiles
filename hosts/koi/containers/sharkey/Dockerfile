FROM registry.activitypub.software/transfem-org/sharkey:develop@sha256:44289651333c9fe6dd11773c42d631bcc3a7e9ba78de5b17b31654e1b731e598

COPY patches /patches

RUN apk add patch && \
    patch -p0 < /patches/zond.patch && \
    patch -p0 < /patches/software.patch
