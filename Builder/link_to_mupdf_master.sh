#!/usr/bin/env bash
#. ~/.profile

# get the location of this script, we will checkout mupdf into the same directory
BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $BUILD_DIR

VERSION_TAG="master"
git clone --recursive git://git.ghostscript.com/mupdf.git --branch $VERSION_TAG mupdf-$VERSION_TAG



MUPDF_ROOT=$BUILD_DIR/mupdf-$VERSION_TAG

MUPDF_JAVA=$MUPDF_ROOT/platform/librera
mkdir -p $MUPDF_JAVA/jni

SRC=jni/~mupdf-$VERSION_TAG
DEST=$MUPDF_ROOT/source
LIBS=$BUILD_DIR/../app/src/main/jniLibs


echo "MUPDF :" $VERSION_TAG
echo "================== "
mkdir mupdf-$VERSION_TAG

cd mupdf-$VERSION_TAG

echo "=================="

if [ "$1" == "reset" ]; then
  git reset --hard
  git clean -f -d
  git submodule foreach --recursive git clean -xfd
  git checkout --recurse-submodules 70430d0a2eabbab85b3515a8c01f41981f4afae4

  echo "=================="
  git log -n 3
  echo "=================="
  rm -rf generated
  make clean
  make generate
  make release
fi



make generate

echo "=================="

cd ..


rm -rf  $MUPDF_JAVA/jni
cp -rRp jni $MUPDF_JAVA/jni
mv $MUPDF_JAVA/jni/Android-$VERSION_TAG.mk $MUPDF_JAVA/jni/Android.mk


rm -r $LIBS
mkdir $LIBS

ln -s $MUPDF_JAVA/libs/armeabi-v7a $LIBS
ln -s $MUPDF_JAVA/libs/arm64-v8a $LIBS
ln -s $MUPDF_JAVA/libs/x86 $LIBS
ln -s $MUPDF_JAVA/libs/x86_64 $LIBS


cp -rpv $SRC/css-apply.c         $DEST/html/css-apply.c
cp -rpv $SRC/epub-doc.c          $DEST/html/epub-doc.c
cp -rpv $SRC/html-layout.c       $DEST/html/html-layout.c
cp -rpv $SRC/html-parse.c        $DEST/html/html-parse.c

cp -rpv $SRC/mucbz.c             $DEST/cbz/mucbz.c
cp -rpv $SRC/muimg.c             $DEST/cbz/muimg.c
cp -rpv $SRC/image-imp.h         $DEST/fitz/image-imp.h
cp -rpv $SRC/load-webp.c         $DEST/fitz/load-webp.c
cp -rpv $SRC/image.c             $DEST/fitz/image.c

cp -rpv $SRC/compressed-buffer.h $MUPDF_ROOT/include/mupdf/fitz/compressed-buffer.h
cp -rpv $SRC/context.h $MUPDF_ROOT/include/mupdf/fitz/context.h



cd $MUPDF_JAVA

if [ "$1" == "clean_ndk" ]; then
/home/dev/Android/Sdk/ndk/25.1.8937393/ndk-build clean
rm -rf $MUPDF_JAVA/obj
fi

/home/dev/Android/Sdk/ndk/25.1.8937393/ndk-build NDK_APPLICATION_MK=jni/Application-19.mk

echo "=================="
echo "MUPDF:" $MUPDF_JAVA
echo "LIBS:"  $LIBS
echo "=================="
