#!/bin/sh

SRC_PATH=$(pwd)/src
BUILD_PATH=$(pwd)/build
BIN_PATH=$BUILD_PATH/bin
PKG_CONFIG_PATH_=$BUILD_PATH/lib/pkgconfig
JOBS=10


case $1 in
	libx264)
		#libx264
		cd $SRC_PATH && \
		git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
		cd x264 && \
		PATH="$BIN_PATH:$PATH" PKG_CONFIG_PATH=$PKG_CONFIG_PATH_ ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" --enable-shared --enable-pic && \
		PATH="$BIN_PATH:$PATH" make -j$JOBS && \
		make install
	;;
	libx265)
		#libx265
		#sudo apt-get install libnuma-dev && \
		cd $SRC_PATH && \
		wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2 && \
		tar xjvf x265.tar.bz2 && \
		cd multicoreware*/build/linux && \
		PATH="$BIN_PATH:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$BUILD_PATH" -DENABLE_SHARED=on ../../source && \
		PATH="$BIN_PATH:$PATH" make -j$JOBS && \
		make install
	;;

	libvpx)
		#libvpx
		cd $SRC_PATH && \
		git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
		cd libvpx && \
		PATH="$BIN_PATH/bin:$PATH" ./configure --prefix="$BUILD_PATH" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --enable-shared --as=yasm && \
		PATH="$BIN_PATH/bin:$PATH" make -j$JOBS && \
		make install
	;;

	libfdk-aac)
		#libfdk-aac
		cd $SRC_PATH && \
		git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
		cd fdk-aac && \
		autoreconf -fiv && \
		./configure --prefix="$BUILD_PATH" && \
		make -j$JOBS && \
		make install
	;;

	libopus)
		#libopus
		cd $SRC_PATH && \
		git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
		cd opus && \
		./autogen.sh && \
		./configure --prefix="$BUILD_PATH" && \
		make -j$JOBS && \
		make install
	;;

	libaom)
		#libaom
		cd $SRC_PATH && \
		git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
		mkdir -p aom_build && \
		cd aom_build && \
		PATH="$BUILD_PATH/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$BUILD_PATH" -DENABLE_TESTS=OFF -DENABLE_NASM=on -DBUILD_SHARED_LIBS=1 ../aom && \
		PATH="$BUILD_PATH/bin:$PATH" make -j$JOBS && \
		make install
	;;

	libsvtav1)
		#libsvtav1
		cd $SRC_PATH && \
		git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
		mkdir -p SVT-AV1/build && \
		cd SVT-AV1/build && \
		PATH="$BUILD_PATH/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$BUILD_PATH" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=ON .. && \
		PATH="$BUILD_PATH/bin:$PATH" make -j$JOBS && \
		make install
	;;

	libdav1d)
		#libdav1d
		#sudo apt-get install python3-pip && \
		#pip3 install --user meson
		cd $SRC_PATH && \
		git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git && \
		mkdir -p dav1d/build && \
		cd dav1d/build && \
		meson setup -Denable_tools=false -Denable_tests=false --default-library=shared .. --prefix "$BUILD_PATH" --libdir="$BUILD_PATH/lib" && \
		ninja -j$JOBS && \
		ninja install
	;;
	libvmaf)
		#libvmaf
		cd $SRC_PATH && \
		wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz && \
		tar xvf v2.1.1.tar.gz && \
		mkdir -p vmaf-2.1.1/libvmaf/build &&\
		cd vmaf-2.1.1/libvmaf/build && \
		meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=shared .. --prefix "$BUILD_PATH" --bindir="$BIN_PATH" --libdir="$BUILD_PATH/lib" && \
		ninja -j$JOBS && \
		ninja install
	;;
	ffmpeg)
		cd $SRC_PATH && \
		wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
		tar xjvf ffmpeg-snapshot.tar.bz2 && \
		cd ffmpeg && \
		PATH="$BIN_PATH:$PATH" PKG_CONFIG_PATH=$PKG_CONFIG_PATH_ ./configure \
		  --prefix="$BUILD_PATH" \
		  --extra-cflags="-I$BUILD_PATH/include" \
		  --extra-ldflags="-L$BUILD_PATH/lib" \
		  --extra-libs="-lpthread -lm" \
		  --ld="g++" \
		  --bindir="$BIN_PATH" \
		  --enable-shared \
		  --enable-gpl \
		  --enable-libaom \
		  --enable-libfdk-aac \
		  --enable-libopus \
		  --enable-libsvtav1 \
		  --enable-libdav1d \
		  --enable-libvpx \
		  --enable-libx264 \
		  --enable-libx265 \
		  --enable-nonfree && \
		PATH="$BIN_PATH:$PATH" make -j$JOBS && \
		make install && \
		hash -r
	;;
	all)
		./build.sh libx264
		./build.sh libx265
		./build.sh libvpx
		./build.sh libfdk-aac
		./build.sh libopus
		./build.sh libaom
		./build.sh libsvtav1
		./build.sh libdav1d
		./build.sh libvmaf
		./build.sh ffmpeg
	;;
	clean_src)
		yes | rm -r src/*
	;;
	clean_bin)
		yes | rm -r bin/*
	;;
	clean_build)
		yes | rm -r build/*
	;;
esac

