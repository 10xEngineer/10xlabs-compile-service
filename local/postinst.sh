#!/bin/sh

compile_root=/opt/compile

cd $compile_root/$DPKG_MAINTSCRIPT_PACKAGE

if [ -f Gemfile ]; then
	bundle install
fi

if [ -x sbin/setup ]; then
	./sbin/setup
fi
