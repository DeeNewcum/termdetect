#!/bin/bash

VER=$(perl -nle 'print $1 if /constant VERSION => "(.*)"/' ../src/termdetect)
SUBDIR=termdetect-$VER
DIR=/var/tmp/$SUBDIR


rm *.tar.bz2
rm /var/tmp/termdetect-$VER.tar*

mkdir -p $DIR
rm -f $DIR/*


cp README.txt $DIR

pushd ../src
make clean
make
cp termdetect.fatpacked $DIR/termdetect
cp termmatch.src $DIR
cp termping $DIR

cd ../
cp LICENSE.txt $DIR

cd /var/tmp
tar -cvf termdetect-$VER.tar $SUBDIR/*
bzip2 termdetect-$VER.tar

popd
mv /var/tmp/termdetect-$VER.tar.bz2 .

rm -f $DIR/*
rmdir $DIR

echo
ls -l --si termdetect-$VER.tar.bz2
echo
tar -tvjf termdetect-$VER.tar.bz2

perl -le 'select undef, undef, undef, 0.2'
