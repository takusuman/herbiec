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
	copadocker_image_hash='sha256:fc28c6cabfb650fc4587482b7b1ae3fe849507441d3203b9377540fa6a468698'
	
	[ -z $program_to_run ] && usage

	docker run -v "$program_to_run:/var/rinha/source.rinha.json" ${2-$copadocker_image_hash}
}

usage() {
	printf 'usage: %s: file.json [docker image hash]\n' $progname 1>&2
	exit 1
}

go "$@"
