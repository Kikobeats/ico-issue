FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

ARG IM_VERSION=7.1.0-16
ARG LIB_HEIF_VERSION=1.12.0
ARG LIB_AOM_VERSION=3.2.0
ARG LIB_WEBP_VERSION=1.2.1

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y git make gcc pkg-config autoconf curl g++ \
    # libaom
    yasm cmake \
    # libheif
    libde265-0 libde265-dev libjpeg-turbo8 libjpeg-turbo8-dev x265 libx265-dev libtool \
    # IM
    libpng16-16 libpng-dev libjpeg-turbo8 libjpeg-turbo8-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev fonts-dejavu && \
    # Building libwebp
    git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && git checkout v${LIB_WEBP_VERSION} && \
    ./autogen.sh && ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no && \
    make && make install && \
    ldconfig /usr/local/lib && \
    cd ../ && rm -rf libwebp && \
    # Building libaom
    git clone https://aomedia.googlesource.com/aom && \
    cd aom && git checkout v${LIB_AOM_VERSION} && cd .. && \
    mkdir build_aom && \
    cd build_aom && \
    cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1 && make && make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -rf aom && \
    rm -rf build_aom && \
    # Building libheif
    curl -L https://github.com/strukturag/libheif/releases/download/v${LIB_HEIF_VERSION}/libheif-${LIB_HEIF_VERSION}.tar.gz -o libheif.tar.gz && \
    tar -xzvf libheif.tar.gz && cd libheif-${LIB_HEIF_VERSION}/ && ./autogen.sh && ./configure && make && make install && cd .. && \
    ldconfig /usr/local/lib && \
    rm -rf libheif-${LIB_HEIF_VERSION} && rm libheif.tar.gz && \
    # Building ImageMagick
    git clone https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && git checkout ${IM_VERSION} && \
    ./configure --without-magick-plus-plus --disable-docs --disable-static --with-tiff && \
    make && make install && \
    ldconfig /usr/local/lib && \
    apt-get remove --autoremove --purge -y gcc make cmake g++ yasm git autoconf pkg-config libpng-dev libjpeg-turbo8-dev libde265-dev libx265-dev libxml2-dev libtiff-dev libfontconfig1-dev libfreetype6-dev && \
    rm -rf /ImageMagick

# Install NodeJS
RUN curl --silent --location https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get -qq install nodejs && \
  npm install -g npm@latest

# clean
RUN rm -rf /var/lib/apt/lists/*

COPY package.json .
RUN npm install --package-lock=false --production && npm dedupe
COPY . .

CMD [ "node", "index.js" ]
