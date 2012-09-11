#!/bin/sh

app_dir=/opt/10xlabs/compile/
tmpdir=`mktemp -d /tmp/compile-service.XXXXXXXX` || exit 1

echo "Using temporary folder $tmpdir"

target_dir="${tmpdir}${app_dir}"

mkdir -p ${target_dir}
cp -R bin ${target_dir}
cp -R share ${target_dir}
cp README.md ${target_dir}

fpm -s dir -t deb -d 'curl' -n 10xlabs-compile-service -v 0.1 -a all --exclude local/* --exclude build.sh --exclude compile_kits -C $tmpdir .

#rm -Rf $tmpdir