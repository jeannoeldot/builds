#!/bin/sh

set -x

cd boost-1.39.0-2
#%define sonamever 5
#Version: 1.39.0

SONAMEVER="5"
VERSION="1.39.0"

# install librairies
for i in `find stage -type f -name \*.a`; do
  NAME=`basename $i`;
  install -p -m 0644 $i usr/lib/$NAME;
done;


for i in `find stage -name \*.so`; do
  NAME=$i;
  SONAME=$i.$SONAMEVER;
  VNAME=$i.$VERSION;
  base=`basename $i`;
  NAMEbase=$base;
  SONAMEbase=$base.$SONAMEVER;
  VNAMEbase=$base.$VERSION;
  mv $i $VNAME;

#  # remove rpath
#  chrpath --delete $VNAME;

  ln -s $VNAMEbase $SONAME;
  ln -s $VNAMEbase $NAME;
  install -p -m 755 $VNAME usr/lib/$VNAMEbase; 

  mv $SONAME usr/lib/$SONAMEbase;
  mv $NAME usr/lib/$NAMEbase;
done;

set +x
