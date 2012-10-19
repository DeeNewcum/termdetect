#!/bin/bash

VER=0.10
DIR=/var/tmp/termdetect


rm *.tar.bz2

mkdir -p $DIR
rm -f $DIR/*

pushd ../src
make clean
make
cp termdetect.fatpacked $DIR/termdetect
cp termmatch.src $DIR

cd ../
cp LICENSE.txt $DIR
cp termping $DIR

cd $DIR
tar -cvf termdetect-$VER.tar *
bzip2 termdetect-$VER.tar

popd
mv $DIR/termdetect-$VER.tar.bz2 .

rm -f $DIR/*
rmdir $DIR

echo
ls -l --si termdetect-$VER.tar.bz2
echo
tar -tvjf termdetect-$VER.tar.bz2
