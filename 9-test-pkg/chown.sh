#!/bin/sh

#cd /home/jnd/01-dev/00-qdev/progtestqt4_01/data


set -x

# le rep à modifier est passé en paramètre
LE_REP=$1

if [ -d $LE_REP ]; then

  echo "REPERTOIRE -> : $LE_REP"

  for file0 in `find $LE_REP` ; do
	  if [ -f $file0 ] ; then
		  # It's a file
#		  chmod 644 $file0
		  chown root:root $file0
#		  echo "--> fichier : $file0"
	  else
		  # It's a directory
#		  chmod 755 $file0
		  chown root:root $file0
#		  echo "--> repertoire : $file0"
	  fi
  done

fi


set +x

