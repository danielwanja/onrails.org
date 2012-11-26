#!/bin/sh

# install wget, which is cleverer than curl
curl -O http://ftp.gnu.org/gnu/wget/wget-1.11.tar.gz
tar zxvf wget-1.11.tar.gz
cd wget-1.11
./configure --prefix=/usr/local
make
sudo make install
cd /usr/local/src

# prerequisite packages
wget http://nongnu.askapache.com/freetype/freetype-2.3.9.tar.gz
tar zxvf freetype-2.3.9.tar.gz
cd freetype-2.3.9
./configure --prefix=/usr/local
make
sudo make install
cd /usr/local/src

wget http://superb-west.dl.sourceforge.net/sourceforge/libpng/libpng-1.2.39.tar.gz
tar zxvf libpng-1.2.39.tar.gz
cd libpng-1.2.39
./configure --prefix=/usr/local
make
sudo make install
cd /usr/local/src

wget ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6b.tar.gz
tar xzvf jpegsrc.v6b.tar.gz
cd jpeg-6b
ln -s `which glibtool` ./libtool
export MACOSX_DEPLOYMENT_TARGET=10.6
./configure --enable-shared --prefix=/usr/local
make
sudo make install
cd /usr/local/src

wget ftp://ftp.remotesensing.org/libtiff/tiff-3.9.1.tar.gz
tar xzvf tiff-3.9.1.tar.gz
cd tiff-3.9.1
./configure --prefix=/usr/local
make
sudo make install
cd /usr/local/src

wget http://superb-west.dl.sourceforge.net/sourceforge/wvware/libwmf-0.2.8.4.tar.gz
tar xzvf libwmf-0.2.8.4.tar.gz
cd libwmf-0.2.8.4
make clean
./configure
make
sudo make install
cd /usr/local/src

wget http://www.littlecms.com/lcms-1.17.tar.gz
tar xzvf lcms-1.17.tar.gz
cd lcms-1.17
make clean
./configure
make
sudo make install
cd /usr/local/src

wget ftp://mirror.cs.wisc.edu/pub/mirrors/ghost/GPL/gs870/ghostscript-8.70.tar.gz
tar zxvf ghostscript-8.70.tar.gz
cd ghostscript-8.70
./configure  --prefix=/usr/local
make
sudo make install
cd /usr/local/src

wget ftp://mirror.cs.wisc.edu/pub/mirrors/ghost/GPL/gs860/ghostscript-fonts-std-8.11.tar.gz
tar zxvf ghostscript-fonts-std-8.11.tar.gz
sudo mv fonts /usr/local/share/ghostscript

# Image Magick
wget ftp://ftp.fifi.org/pub/ImageMagick/ImageMagick.tar.gz
tar xzvf ImageMagick.tar.gz
cd `ls | grep ImageMagick-`
export CPPFLAGS=-I/usr/local/include
export LDFLAGS=-L/usr/local/lib
./configure --prefix=/usr/local --disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8 --with-gs-font-dir=/usr/local/share/ghostscript/fonts --disable-openmp
make
sudo make install
cd /usr/local/src

# RMagick
sudo gem install rmagick