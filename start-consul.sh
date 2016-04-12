#!/usr/bin/env bash

main() {
	set -eo pipefail
	case "$1" in
	*)           exec /bin/consul agent -config-dir=/consul/config $@;;
	esac
}

main "$@"
