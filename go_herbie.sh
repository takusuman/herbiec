#!/bin/sh
# go_herbie.sh - script simples para executar a imagem Docker com o herbiec
#
# Copyright (c) 2023 Luiz Antônio Rangel
# 
# SPDX-Licence-Identifier: ISC 

progname=${0##*/}

go() {
	docker_path="`command -v docker`"
	program_to_run="`readlink -f $1 2>/dev/null`"
	copadocker_image_hash='sha256:cfe962e9b5850bff2296c1bb462d9bca25702deab2b61a9b30503493c0fab805'
	
	[ -z $program_to_run ] && usage

	docker run -v "$program_to_run:/var/rinha/source.rinha.json" ${copadocker_image_hash:-$2}
}

usage() {
	printf 'usage: %s: file.json [docker image hash]\n' $progname 1>&2
	exit 1
}

go "$@"
