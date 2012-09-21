#!/usr/bin/env bash

# list of compile kits
declare -a KITS=()
dir_list=`ls -l compile_kits/ | egrep '^d' | awk '{print $9}'`
for f in $dir_list; do
	[[ -d compile_kits/$f ]] && KITS=("${KITS[@]}" "$f")
done

function prepare_kit() {
	kit=$1

	current=`pwd`
	kit_dir=/opt/compile/$kit
	tmpdir=`mktemp -d /tmp/kit.XXXXXXXX` || exit 1

	echo "Building $kit"

	cd compile_kits/$kit

	target_dir=${tmpdir}${kit_dir}
	mkdir -p $target_dir

	cp -R bin $target_dir
	cp -R etc $target_dir
	cp -R sbin $target_dir

	version=`cat etc/version`

	cd $current

    # -d '10xlabs-compile-service' 
	fpm -s dir -t deb -n $kit -v $version -a all --after-install local/postinst.sh -C $tmpdir .
	rm -Rf $tmpdir
}


for kit in ${KITS[@]}; do
	prepare_kit $kit
done
