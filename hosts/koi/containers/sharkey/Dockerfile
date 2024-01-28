FROM git.joinsharkey.org/sharkey/sharkey:develop@sha256:f1af3284adfaca63326394b0a3a585d9c74b43fc6f684236fd8ff83b06f27e57

COPY patches /patches

RUN apk add patch && \
    patch -p0 < /patches/fake-deepl-server.patch && \
    patch -p0 < /patches/zond.patch