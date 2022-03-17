# ==================================================================================================================
#
# Docker to ubuntu 18.04 base image (for required libraries) used by GCBM
#
# Building this Docker:
#   docker build --build-arg NUM_CPU=4 -t moja/gcbm:ubuntu-18.04 .
#
# ==================================================================================================================

# moja.canada
# RUN cd $ROOTDIR/src && git clone -b develop https://github.com/moja-global/moja.canada

FROM ghcr.io/harshcasper/moja.canada.base:gha-ci

WORKDIR $ROOTDIR/src

RUN mkdir -p moja.canada

COPY . ./moja.canada

WORKDIR $ROOTDIR/src/moja.canada/Source/build
RUN cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
           -DCMAKE_INSTALL_PREFIX=/usr/local \
           -DENABLE_TESTS:BOOL=OFF \
           -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/ \
           .. \
    && make --quiet -s -j $NUM_CPU \
    && make --quiet install \
    && make clean

WORKDIR $ROOTDIR/src
RUN mkdir -p /opt/gcbm
RUN ln -t /opt/gcbm /usr/local/lib/lib*
RUN ln -t /opt/gcbm /usr/local/bin/moja.cli
RUN rm -rf /usr/local/src/*
RUN rm -rf /tmp/*

#WORKDIR /opt/gcbm
#ENTRYPOINT ["./moja.cli"]
