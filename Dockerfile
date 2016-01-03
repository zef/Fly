# based on
# https://developer.ibm.com/swift/2015/12/15/running-swift-within-docker/
#
# Modifications:
# added git
# copy dir of files

FROM ubuntu:15.10

# Latest Swift Version
ENV SWIFT_VERSION 2.2-SNAPSHOT-2015-12-01-b
ENV SWIFT_PLATFORM ubuntu15.10
# Install Dependencies
RUN apt-get update && \
    apt-get install -y \
        git \
        clang \
        libicu55 \
        libpython2.7 \
        wget

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Download and install Swift
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget $SWIFT_URL && \
    wget $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz -C / --strip 1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*


# For https://github.com/Zewo/Epoch
RUN apt-get install -y software-properties-common
RUN apt-get update && add-apt-repository 'deb [trusted=yes] http://apt.zewo.io/deb ./' | tee --append /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes uri-parser http-parser libvenice

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#Building a webserver? Expose Port 80 by uncommenting the following.
Expose 8080

# COPY ./ /Fly

WORKDIR /Fly
# RUN swift build

# ENTRYPOINT .build/debug/Fly
