# DOCKER-VERION:	1.9.1
# DESCRIPTION:		Image with private webpagetest (www.webpagetest.org)
# TO_BUILD:		docker build -rm -t wpt .
# TO_RUN:		docker run -d --publish 80:80 --volume /tmp/wpt/results:/var/www/html/results webpagetest

FROM centos:centos6
MAINTAINER Yunkyung Lee <yunkyung@gmail.com>

# for httpd, php 
RUN yum install -y httpd
RUN yum install -y php php-devel php-pear php-mysql php-mbstring php-gd php-imap php-odbc php-xmlrpc php-xml
RUN yum install -y gd gd-devel php-gd

# PHP
RUN sed -ri 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php.ini
RUN sed -ri 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
RUN sed -ri 's/post_max_size = 8M/post_max_size = 15M/g' /etc/php.ini
RUN sed -ri 's/memory_limit = 128M/memory_limit = -1/g' /etc/php.ini

# System Utilities
# ffmpeg for video recording
# based on Julien Rottenberg <julien@rottenberg.info>
# based on docker image  rottenberg/ffmpeg
# From https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
ENV	FFMPEG_VERSION  2.8
ENV     MPLAYER_VERSION 1.1.1
ENV     YASM_VERSION    1.2.0
ENV     LAME_VERSION    3.99.5
ENV     FAAC_VERSION    1.28
ENV     XVID_VERSION    1.3.3
ENV     FDKAAC_VERSION  0.1.3
ENV     EXIFTOOL_VERSION 9.75
# from https://github.com/WPO-Foundation/webpagetest base on pmeenan
ENV     WPT_VERSION 2.18
ENV     SRC             /usr/local
ENV     LD_LIBRARY_PATH ${SRC}/lib
ENV     PKG_CONFIG_PATH ${SRC}/lib/pkgconfig

ENV 	PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:  

RUN bash -c 'set -euo pipefail'

RUN yum install -y autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel tar curl wget bzip2
# yasm
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -Os http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz && \
              tar xzvf yasm-${YASM_VERSION}.tar.gz && \
              cd yasm-${YASM_VERSION} && \
              ./configure --prefix="$SRC" --bindir="${SRC}/bin" && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# x264
RUN DIR=$(mktemp -d) && cd ${DIR} && \
	      curl -Os ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 &&	\
	      tar xvf last_x264.tar.bz2 &&	\
              cd x264* && \
              ./configure --prefix="$SRC" --bindir="${SRC}/bin" --enable-static && \
              make && \
              make install && \
              make distclean&& \
              rm -rf ${DIR}

# libmp3lame
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -Os http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz  && \
              tar xzvf lame-${LAME_VERSION}.tar.gz  && \
              cd lame-${LAME_VERSION} && \
              ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --disable-shared --enable-nasm && \
              make && \
              make install && \
              make distclean&& \
              rm -rf ${DIR}

# faac + http://stackoverflow.com/a/4320377
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -Os http://downloads.sourceforge.net/faac/faac-${FAAC_VERSION}.tar.gz  && \
              tar xzvf faac-${FAAC_VERSION}.tar.gz  && \
              cd faac-${FAAC_VERSION} && \
              sed -i '126d' common/mp4v2/mpeg4ip.h && \
              ./bootstrap && \
              ./configure --prefix="${SRC}" --bindir="${SRC}/bin" && \
              make && \
              make install &&	\
              rm -rf ${DIR}

# xvid
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -Os  http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz  && \
              tar xzvf xvidcore-${XVID_VERSION}.tar.gz && \
              cd xvidcore/build/generic && \
              ./configure --prefix="${SRC}" --bindir="${SRC}/bin" && \
              make && \
              make install&& \
              rm -rf ${DIR}


# fdk-aac
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s https://codeload.github.com/mstorsjo/fdk-aac/tar.gz/v${FDKAAC_VERSION} | tar zxvf - && \
              cd fdk-aac-${FDKAAC_VERSION} && \
              autoreconf -fiv && \
              ./configure --prefix="${SRC}" --disable-shared && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# ffmpeg
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -Os http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
              tar xzvf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
              cd ffmpeg-${FFMPEG_VERSION} && \
              ./configure --prefix="${SRC}" --extra-cflags="-I${SRC}/include" --extra-ldflags="-L${SRC}/lib" --bindir="${SRC}/bin" \
              --extra-libs=-ldl --enable-version3 --enable-libfaac --enable-libmp3lame --enable-libx264 --enable-libxvid --enable-gpl \
              --enable-postproc --enable-nonfree --enable-avresample --enable-libfdk_aac --disable-debug --enable-small && \
              make && \
              make install && \
              make distclean && \
              hash -r && \
              rm -rf ${DIR}

# mplayer
#RUN DIR=$(mktemp -d) && cd ${DIR} && \
#              curl -Os http://mplayerhq.hu/MPlayer/releases/MPlayer-${MPLAYER_VERSION}.tar.xz && \
#              tar xvf MPlayer-${MPLAYER_VERSION}.tar.xz && \
#              cd MPlayer-${MPLAYER_VERSION} && \
#              ./configure --prefix="${SRC}" --extra-cflags="-I${SRC}/include" --extra-ldflags="-L${SRC}/lib" --bindir="${SRC}/bin" && \
#              make && \
#              make install && \
#              rm -rf ${DIR}

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/libc.conf

## install ImageMagick
RUN yum install -y ImageMagick ImageMagick-devel ImageMagick-perl

## install Jpegtran 
RUN yum -y install libjpeg-turbo-devel libjpeg-turbo-static libjpeg-turbo

## install exiftool
RUN yum install -y perl-devel
RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -Os http://owl.phy.queensu.ca/~phil/exiftool/Image-ExifTool-${EXIFTOOL_VERSION}.tar.gz && \
              tar xvf Image-ExifTool-${EXIFTOOL_VERSION}.tar.gz && \
              cd Image-ExifTool-${EXIFTOOL_VERSION} && \
              perl Makefile.PL && \
              make install  && \
	      cp -r exiftool lib /usr/bin && \
              rm -rf ${DIR}

# Filesystem setting
RUN mkdir -p /var/www/html/tmp &&	\
	chmod 777 /var/www/html/tmp &&	\
	mkdir -p /var/www/html/dat &&	\
	chmod 777 /var/www/html/dat &&	\
	mkdir -p /var/www/html/results &&	\
	chmod 777 /var/www/html/results &&	\
	mkdir -p /var/www/html/work/jobs &&	\
	chmod 777 /var/www/html/work/jobs &&	\
	mkdir -p /var/www/html/work/video &&	\
	chmod 777 /var/www/html/work/video &&	\
	mkdir -p /var/www/html/logs &&	\
	chmod 777 /var/www/html/logs 

RUN DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -Os https://github.com/WPO-Foundation/webpagetest/archive/WebPageTest-${WPT_VERSION}.tar.gz  && \
              tar xvf WebPageTest-${WPT_VERSION}.tar.gz && \
              cd webpagetest-WebPageTest-${WPT_VERSION} && \
              cp -r www/*  /var/www/html/ 

COPY locations.ini /var/www/html/settings/
COPY connectivity.ini /var/www/html/settings/
COPY settings.ini /var/www/html/settings/

# test results store volume
VOLUME ["/var/www/html/results"] 

EXPOSE 80
CMD ["/usr/sbin/httpd", "-k", "start", "-D", "FOREGROUND"]
