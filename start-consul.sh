#!/usr/bin/env bash

main() {
	set -eo pipefail
	case "$1" in
	*)           exec /bin/consul agent -config-file=/consul/config.json -config-dir=/consul/config $@;;
	esac
}

main "$@"
