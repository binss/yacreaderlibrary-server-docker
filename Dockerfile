FROM debian:buster AS builder
MAINTAINER muallin@gmail.com

WORKDIR /src
WORKDIR git

# Update system
RUN apt-get update && \
    apt-get -y install qt5-image-formats-plugins p7zip-full git dumb-init qt5-default libpoppler-qt5-dev libpoppler-qt5-1 wget unzip libqt5sql5-sqlite libqt5sql5 sqlite3 libqt5network5 libqt5gui5 libqt5core5a build-essential
RUN git clone https://github.com/YACReader/yacreader.git . && \
    git checkout 9.8.1
RUN cd compressed_archive/unarr/ && \
    wget github.com/selmf/unarr/archive/master.zip &&\
    unzip master.zip  &&\
    rm master.zip &&\
    cd unarr-master/lzmasdk &&\
    ln -s 7zTypes.h Types.h
#RUN cd compressed_archive/ &&\
#    git clone https://github.com/btolab/p7zip ./libp7zip
RUN cd /src/git/YACReaderLibraryServer && \
#    qmake "CONFIG+=7zip server_standalone" YACReaderLibraryServer.pro && \
    qmake "CONFIG+=server_standalone" YACReaderLibraryServer.pro && \
    make  && \
    make install

FROM alpine:latest  

RUN apk --no-cache add poppler-qt5 qt5-qtbase libc6-compat qt5-qtbase-sqlite

WORKDIR /usr/bin

COPY --from=builder /usr/bin/YACReaderLibraryServer .
COPY --from=builder /src/git/release /usr/share/yacreader/

ADD YACReaderLibrary.ini /root/.local/share/YACReader/YACReaderLibrary/

#ADD entrypoint.sh /
#RUN /bin/sh -c 'chmod +x /entrypoint.sh'

# add specific volumes: configuration, comics repository, and hidden library data to separate them
VOLUME ["/config", "/comics", "/comics/.yacreaderlibrary"]

EXPOSE 8080

ENV LC_ALL=C.UTF8

ENTRYPOINT ["YACReaderLibraryServer","start"]
